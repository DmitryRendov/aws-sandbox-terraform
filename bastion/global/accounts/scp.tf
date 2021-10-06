# This file is for Service Control Policies within the bastion organization. You can
# then attach these policies to other accounts using the aws-organization-account module.

# This policy is to deny disallowed Regions in the organization
data "aws_iam_policy_document" "deny_disallowed_regions" {
  statement {
    sid = "DenyDisallowedRegions"

    not_actions = [
      "a4b:*",
      "artifact:*",
      "aws-portal:*",
      "budgets:*",
      "ce:*",
      "chime:*",
      "cloudfront:*",
      "cur:*",
      "datapipeline:GetAccountLimits",
      "directconnect:*",
      "globalaccelerator:*",
      "health:*",
      "iam:*",
      "importexport:*",
      "mobileanalytics:*",
      "organizations:*",
      "resource-groups:*",
      "route53:*",
      "route53domains:*",
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets",
      "shield:*",
      "support:*",
      "tag:*",
      "trustedadvisor:*",
      "waf:*",
      "wellarchitected:*",
      "sts:*",
    ]

    resources = ["*"]

    effect = "Deny"

    condition {
      test     = "StringNotEquals"
      variable = "aws:RequestedRegion"

      values = var.allowed_regions
    }
  }
}

resource "aws_organizations_policy" "deny_disallowed_regions" {
  name        = "DenyAllRegionsExceptAreInUse"
  description = "Allow access to any operations only within the specified regions."

  content = data.aws_iam_policy_document.deny_disallowed_regions.json
}

# This is to restrict deletion of non-current version of objects in all S3 buckets
data "aws_iam_policy_document" "s3_deny_version_deletion" {
  statement {
    sid = "DenyDeleteS3VersionedObjects"

    actions = [
      "s3:DeleteObjectVersion",
      "s3:DeleteObjectVersionTagging"
    ]

    resources = ["*"]

    effect = "Deny"

  }
}

resource "aws_organizations_policy" "s3_deny_version_deletion" {
  name        = "DisableIAMS3DeleteNonCurrentVersions"
  description = "Disable ability to delete non-current versions of S3 objects."

  content = data.aws_iam_policy_document.s3_deny_version_deletion.json
}
