##
# ORG custom AWS Config rules
#
module "s3_bucket_encryption_custom" {
  count  = local.config_enabled ? 1 : 0
  source = "./rules/s3_bucket_encryption_custom"

  exclude_accounts = local.exclude_accounts
  aws_account_map  = var.aws_account_map
  aws_account_ids  = distinct(values(var.aws_account_map))

  org_lambda_role_id               = aws_iam_role.org_lambda_role.id
  org_lambda_cross_account_role_id = module.org_lambda_cross_account_role_label.id
}

module "s3_bucket_encryption_custom_east" {
  count  = local.config_enabled ? 1 : 0
  source = "./rules/s3_bucket_encryption_custom"

  exclude_accounts = local.exclude_accounts
  aws_account_map  = var.aws_account_map
  aws_account_ids  = distinct(values(var.aws_account_map))

  org_lambda_role_id               = aws_iam_role.org_lambda_role.id
  org_lambda_cross_account_role_id = module.org_lambda_cross_account_role_label.id

  providers = {
    aws = aws.west
  }
}

module "sqs_encryption" {
  count  = local.config_enabled ? 1 : 0
  source = "./rules/sqs_encryption"

  maximum_execution_frequency = local.default_execution_frequency
  exclude_accounts            = local.exclude_accounts
  aws_account_map             = var.aws_account_map
  aws_account_ids             = distinct(values(var.aws_account_map))

  org_lambda_role_id               = aws_iam_role.org_lambda_role.id
  org_lambda_cross_account_role_id = module.org_lambda_cross_account_role_label.id

  input_parameters = {
    "QueueNameStartsWith" = null
  }
}

module "sqs_encryption_east" {
  count  = local.config_enabled ? 1 : 0
  source = "./rules/sqs_encryption"

  maximum_execution_frequency = local.default_execution_frequency
  exclude_accounts            = local.exclude_accounts
  aws_account_map             = var.aws_account_map
  aws_account_ids             = distinct(values(var.aws_account_map))

  org_lambda_role_id               = aws_iam_role.org_lambda_role.id
  org_lambda_cross_account_role_id = module.org_lambda_cross_account_role_label.id

  input_parameters = {
    "QueueNameStartsWith" = null
  }

  providers = {
    aws = aws.west
  }
}
