# S3 bucket for Serverless Lambda Functions
module "serverless_lambdas" {
  source = "../../../modules/base/s3-bucket/v3"
  label  = module.label

  versioning_enabled = false
  backups_enabled    = false

  acl_policy_grants = []

  providers = {
    aws.src = aws
    aws.dst = aws.west
  }
}

module "website" {
  source = "../../../modules/base/s3-website/v1"
  label  = module.website_label

  hostname         = local.hostname
  parent_zone_id   = data.terraform_remote_state.route53.outputs.zone_id
  parent_zone_name = data.terraform_remote_state.route53.outputs.zone_name

  log_bucket         = data.terraform_remote_state.global.outputs.logging_bucket.id
  s3_logs_prefix     = "s3/${local.aws_account_id}"
  versioning_enabled = false

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false

  s3_lifecycle_rules = [
    {
      id                            = "ExpireOldVersions"
      transition                    = []
      tags                          = {}
      enabled                       = true
      expiration                    = []
      prefix                        = ""
      noncurrent_version_transition = []
      noncurrent_version_expiration = [{
        days                         = 1
        expired_object_delete_marker = true
      }]
    }
  ]
}
