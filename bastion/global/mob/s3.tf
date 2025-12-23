# S3 bucket for MON Project
module "mob" {
  source      = "../../../modules/base/s3-bucket/v3"
  label       = module.label
  bucket_name = "mob-server-backups"

  versioning_enabled            = false
  backups_enabled               = false
  transition_to_onezone_ia_days = "30"
  transition_to_glacier_days    = "90"

  providers = {
    aws.src = aws
    aws.dst = aws.west
  }
}

data "aws_iam_policy_document" "private_mob_policy" {

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
        "arn:aws:iam::${var.aws_account_id}:user/${data.terraform_remote_state.global.outputs.admin_username}",
      ]
    }

    resources = [
      module.mob.arn,
      "${module.mob.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "restrict_only_owner" {
  bucket = module.mob.id
  policy = data.aws_iam_policy_document.private_mob_policy.json
}
