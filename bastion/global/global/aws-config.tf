module "aws_config_recorder" {
  source = "../../../modules/base/aws-config-recorder/v2"
  count  = local.config_recorder_enabled ? 1 : 0

  label              = module.label
  delivery_frequency = local.config_recorder_delivery_frequency
  s3_bucket_name     = data.terraform_remote_state.audit.outputs.aws_config_bucket.id

  providers = {
    aws = aws
  }
}

module "aws_config_recorder_west" {
  source = "../../../modules/base/aws-config-recorder/v2"
  count  = local.config_recorder_enabled ? 1 : 0

  label              = module.label
  delivery_frequency = local.config_recorder_delivery_frequency
  s3_bucket_name     = data.terraform_remote_state.audit.outputs.aws_config_bucket.id

  providers = {
    aws = aws.west
  }
}
