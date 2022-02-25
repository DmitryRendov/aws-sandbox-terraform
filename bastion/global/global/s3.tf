# S3 bucket for Private Backups
module "backup" {
  source      = "../../../modules/base/s3-bucket/v1"
  label       = module.label
  bucket_name = "mob-private-backups"

  versioning_enabled = false
  backups_enabled    = false

  providers = {
    aws.src = aws
    aws.dst = aws.west
  }
}

data "aws_iam_policy_document" "private_backups_policy" {

  statement {
    effect = "Allow"

    actions = [
      "s3:*",
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.aws_account_id}:user/${module.dmitry_rendov.name}",
        "arn:aws:iam::${var.aws_account_id}:role/${module.dmitry_rendov.name}",
      ]
    }

    resources = [
      module.backup.arn,
      "${module.backup.arn}/*",
    ]
  }

  statement {
    effect = "Deny"

    actions = [
      "s3:*",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "ForAllValues:StringNotLike"
      variable = "aws:aws:PrincipalArn"
      values = [
        "arn:aws:iam::${var.aws_account_id}:user/${module.dmitry_rendov.name}",
        var.aws_account_id,
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
