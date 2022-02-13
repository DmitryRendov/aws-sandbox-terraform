data "aws_ssm_parameter" "read" {
  count = length(local.parameter_read)
  name  = element(local.parameter_read, count.index)
}

resource "aws_ssm_parameter" "default" {
  for_each = local.parameter_write

  name            = each.key
  description     = each.value.description
  type            = each.value.type
  tier            = each.value.tier
  key_id          = each.value.type == "SecureString" ? var.kms_arn : ""
  value           = each.value.type == "SecureString" ? "not_secret" : each.value.value
  overwrite       = each.value.overwrite
  allowed_pattern = each.value.allowed_pattern
  data_type       = each.value.data_type

  tags = var.label.tags
}

resource "aws_ssm_parameter" "ignore_value_changes" {
  for_each = local.parameter_write_ignore_values

  name            = each.key
  description     = each.value.description
  type            = each.value.type
  tier            = each.value.tier
  key_id          = each.value.type == "SecureString" ? var.kms_arn : ""
  value           = each.value.type == "SecureString" ? "not_secret" : each.value.value
  overwrite       = each.value.overwrite
  allowed_pattern = each.value.allowed_pattern
  data_type       = each.value.data_type

  tags = var.label.tags

  lifecycle {
    ignore_changes = [
      value,
      tier
    ]
  }
}
