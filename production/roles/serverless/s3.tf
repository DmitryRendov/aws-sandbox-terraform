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
