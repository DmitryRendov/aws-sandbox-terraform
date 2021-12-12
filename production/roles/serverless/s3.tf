# S3 bucket for Serverless Lambda Functions
module "serverless_lambdas" {
  source = "../../../modules/base/s3-bucket/v1"
  label  = module.label

  versioning_enabled = false
  backups_enabled    = false

  providers = {
    aws.src = aws
    aws.dst = aws.west
  }
}

module "website" {
  source = "../../../modules/base/s3-website/v1"
  label  = module.website_label

  hostname           = local.hostname
  log_bucket         = data.terraform_remote_state.global.outputs.logging_bucket.id
  s3_logs_prefix     = "s3/${local.aws_account_id}"
  versioning_enabled = false

  s3_lifecycle_rules = [
    {
      id         = "ExpireOldVersions"
      transition = []
      tags       = {}
      enabled    = true
      expiration = [{
        days                         = 1
        expired_object_delete_marker = true
      }]
      prefix                        = ""
      noncurrent_version_transition = []
      noncurrent_version_expiration = [{
        days                         = 1
        expired_object_delete_marker = true
      }]
    }
  ]
}
