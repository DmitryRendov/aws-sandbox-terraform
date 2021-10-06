data "aws_caller_identity" "current" {}

data "external" "git_root" {
  program = ["bash", "-c", "jq -n --arg root \"$(git rev-parse --show-toplevel)\" --arg repo \"$(basename $(git remote get-url origin) .git)\" '{\"root\":$root, \"repo\":$repo}'"]
}

module "check" {
  source = "./required_labels"
  check  = local.input
}

locals {

  ## Add a `repo` tag to help us identify where resources were created
  repo = "${data.external.git_root.result.repo}${replace(path.cwd, data.external.git_root.result.root, "")}"

  defaults = {
    regex_replace_chars = "/[^-a-zA-Z0-9]/"
    delimiter           = "-"
    id_length_limit     = 0
    id_hash_length      = 5
    replacement         = ""
  }

  id_hash_length = local.defaults.id_hash_length

  # The values provided by variables supersede the values inherited from the context object,
  # except for tags and attributes which are merged.
  input = {
    # It would be nice to use coalesce here, but we cannot, because it
    # is an error for all the arguments to coalesce to be empty.

    environment = var.environment == null ? var.context.environment : var.environment
    name        = var.name == null ? var.context.name : var.name
    delimiter   = var.delimiter == null ? var.context.delimiter : var.delimiter
    # modules tack on attributes (passed by var) to the end of the list (passed by context)
    attributes          = compact(distinct(concat(coalesce(var.context.attributes, []), coalesce(var.attributes, []))))
    tags                = merge(var.context.tags, var.tags)
    additional_tag_map  = merge(var.context.additional_tag_map, var.additional_tag_map)
    id_length_limit     = var.id_length_limit == null ? var.context.id_length_limit : var.id_length_limit
    team                = var.team == null ? var.context.team : var.team
    regex_replace_chars = var.regex_replace_chars == null ? var.context.regex_replace_chars : var.regex_replace_chars
    replacement         = var.replacement == null ? var.context.replacement : var.replacement
  }

  replacement         = local.input.replacement == null ? local.defaults.replacement : local.input.replacement
  regex_replace_chars = coalesce(local.input.regex_replace_chars, local.defaults.regex_replace_chars)

  # string_label_names are names of inputs that are strings (not list of strings) used as labels
  # Normalize these values by removing disallowed characters.
  string_label_names = ["name", "environment"]
  normalized_labels = { for k in local.string_label_names : k =>
    local.input[k] == null ? "" : replace(local.input[k], local.regex_replace_chars, local.replacement)
  }
  normalized_attributes = compact(distinct([for v in local.input.attributes : replace(v, local.regex_replace_chars, local.replacement)]))

  # Lower case all the things
  formatted_labels = { for k in local.string_label_names : k => lower(local.normalized_labels[k]) }

  attributes = compact(distinct([
    for v in local.normalized_attributes : lower(v)
  ]))

  name        = local.formatted_labels["name"]
  environment = local.formatted_labels["environment"]

  delimiter = local.input.delimiter == null ? local.defaults.delimiter : local.input.delimiter

  id_length_limit = local.input.id_length_limit == null ? local.defaults.id_length_limit : local.input.id_length_limit

  additional_tag_map = merge(var.context.additional_tag_map, var.additional_tag_map)

  tags = merge(local.generated_tags, local.input.tags)

  tags_as_list_of_maps = flatten([
    for key in keys(local.tags) : merge(
      {
        key   = key
        value = local.tags[key]
    }, var.additional_tag_map)
  ])

  tags_context = {
    attributes  = local.id_context.attributes
    environment = local.environment
    repo        = local.repo
    role        = local.input.name
    team        = local.input.team
  }

  # `Name` is special in AWS, and needs to be title cased.
  generated_tags = merge(
    {
      Name = local.id
    },
    {
      for l in keys(local.tags_context) :
      lower(l) => tostring(local.tags_context[l]) if try(length(local.tags_context[l]), "1") > 0
    },
  )

  id_context = {
    name        = local.name
    environment = local.environment
    attributes  = join(local.delimiter, local.attributes)
  }

  labels = [for l in ["environment", "name", "attributes"] : local.id_context[l] if length(local.id_context[l]) > 0]
  labels_truncated = compact([
    substr(local.id_context["environment"], 0, 4),
    local.id_context["name"],
    local.id_context["attributes"],
  ])


  ## Here is a bunch of magic to generate ids that are not too long.
  ## General logic: If the ID is greater than `id_length_limit`, then generate a new one that is based on truncated environment & name with a hash appended for uniqueness
  ## Then output the longest version we can.
  ## Similarly for S3, our bucket is
  ##   sb-<id>-<12 digit account hash>
  ## If this is too long, it becomes:
  ##   sb-<truncated-id plus unique hash>-<12 digit account hash>

  id_full  = join(local.delimiter, local.labels)
  id_brief = join(local.delimiter, local.labels_truncated)

  # Create a truncated ID if needed
  delimiter_length = length(local.delimiter)
  # Calculate length of normal part of ID, leaving room for delimiter and hash
  id_truncated_length_limit = local.id_length_limit - (local.id_hash_length + local.delimiter_length)
  # Truncate the ID and ensure a single (not double) trailing delimiter
  id_truncated = local.id_truncated_length_limit <= 0 ? "" : "${trimsuffix(substr(local.id_brief, 0, local.id_truncated_length_limit), local.delimiter)}${local.delimiter}"
  # Support usages that disallow numeric characters. Would prefer tr 0-9 q-z but Terraform does not support it.
  id_hash_plus = "${md5(local.id_full)}qrstuvwxyz"
  id_hash_case = lower(local.id_hash_plus)
  id_hash      = replace(local.id_hash_case, local.regex_replace_chars, local.replacement)
  # Create the short ID by adding a hash to the end of the truncated ID
  id_short = substr("${local.id_truncated}${local.id_hash}", 0, local.id_length_limit)
  id       = local.id_length_limit != 0 && length(local.id_full) > local.id_length_limit ? local.id_short : local.id_full

  ## Maximum length for a bucket name is 63, so we subtract 4 for the `sb-` prefix + delimiters and 12 for the account ID SHA (47); then subtract the hash length + delimiter length
  account_id_hash              = substr(sha512(data.aws_caller_identity.current.account_id), 0, 12)
  s3_id_length_limit           = 63                                                                                                          ## max length for S3 bucket name
  s3_short_id_length_limit     = local.s3_id_length_limit - length(format("sb-%s-%s", "", local.account_id_hash))                            # 47
  s3_id_truncated_length_limit = local.s3_id_length_limit - (local.id_hash_length + local.delimiter_length + local.s3_short_id_length_limit) # 41

  s3_id_truncated = "${trimsuffix(substr(local.id_brief, 0, local.s3_id_truncated_length_limit), local.delimiter)}${local.delimiter}"
  s3_id_short     = substr("${local.s3_id_truncated}${local.id_hash}", 0, local.s3_short_id_length_limit)

  s3_bucket_name = replace(
    format(
      "sb-%s-%s",
      length(local.id_full) <= local.s3_short_id_length_limit ? local.id_full : local.s3_id_short,
      local.account_id_hash,
    ),
    "_",
    "-",
  )

  # Context of this label to pass to other label modules
  output_context = {
    name               = local.name
    environment        = local.environment
    delimiter          = local.delimiter
    attributes         = local.attributes
    tags               = local.tags
    additional_tag_map = local.additional_tag_map
    id_length_limit    = local.id_length_limit
    team               = var.team == null ? var.context.team : var.team
  }
}
