# S3 bucket for Private Backups
module "backup" {
  source      = "../../../modules/base/s3-bucket/v3"
  label       = module.label
  bucket_name = "mob-private-backups"

  versioning_enabled            = false
  backups_enabled               = false
  transition_to_onezone_ia_days = "30"
  transition_to_glacier_days    = "90"

  acl_policy_grants = []

  providers = {
    aws.src = aws
    aws.dst = aws.west
  }
}

data "aws_canonical_user_id" "current" {}

data "aws_iam_policy_document" "private_backups_policy" {

  statement {
    effect = "Allow"

    actions = [
      "s3:*",
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.aws_account_id}:root",
        "arn:aws:iam::${var.aws_account_id}:role/super-user",
        "arn:aws:iam::${var.aws_account_id}:user/${module.dmitry_rendov.name}",
      ]
    }

    resources = [
      module.backup.arn,
      "${module.backup.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "restrict_only_owner" {
  bucket = module.backup.id
  policy = data.aws_iam_policy_document.private_backups_policy.json
}
