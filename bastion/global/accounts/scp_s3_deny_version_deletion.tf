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
