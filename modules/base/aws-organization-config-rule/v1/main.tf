##
# ORG Custom Config Rule
#
data "aws_region" "current" {}
data "aws_region" "east" {
  provider = aws.east
}

module "lambda_label" {
  source          = "../../../../modules/site/label/v1"
  context         = var.label.context
  id_length_limit = 64
  attributes      = compact(concat(var.label_attributes, [data.aws_region.current.name]))
}

module "lambda_label_east" {
  source          = "../../../../modules/site/label/v1"
  context         = var.label.context
  id_length_limit = 64
  attributes      = compact(concat(var.label_attributes, [data.aws_region.east.name]))
}

data "aws_iam_role" "org_lambda_role" {
  name = var.org_lambda_role_id
}

resource "aws_lambda_permission" "lambda_permission" {
  count          = length(var.aws_account_ids)
  statement_id   = "AllowExecutionFromCrossAccount-${element(var.aws_account_ids, count.index)}"
  action         = "lambda:InvokeFunction"
  function_name  = module.lambda.function.function_name
  principal      = "config.amazonaws.com"
  source_account = element(sort(var.aws_account_ids), count.index)
}

resource "aws_lambda_permission" "lambda_permission_east" {
  provider       = aws.east
  count          = length(var.aws_account_ids)
  statement_id   = "AllowExecutionFromCrossAccount-${element(var.aws_account_ids, count.index)}"
  action         = "lambda:InvokeFunction"
  function_name  = module.lambda_east.function.function_name
  principal      = "config.amazonaws.com"
  source_account = element(sort(var.aws_account_ids), count.index)
}

module "lambda" {
  source            = "../../../../modules/site/lambda/v7"
  filename          = var.archive_file.output_path
  handler           = var.lambda_handler
  iam_role_arn      = data.aws_iam_role.org_lambda_role.arn
  runtime           = "python3.8"
  source_code_hash  = var.archive_file.output_base64sha256
  s3_bucket         = var.s3_bucket
  s3_key            = var.s3_key
  timeout           = var.timeout
  label             = module.lambda_label
  memory_size       = var.memory_size
  attach_vpc_config = false
  description       = var.description
  variables         = var.lambda_environment_variables
}

module "lambda_east" {
  source            = "../../../../modules/site/lambda/v7"
  filename          = var.archive_file.output_path
  handler           = var.lambda_handler
  iam_role_arn      = data.aws_iam_role.org_lambda_role.arn
  runtime           = "python3.8"
  source_code_hash  = var.archive_file.output_base64sha256
  timeout           = var.timeout
  label             = module.lambda_label_east
  memory_size       = var.memory_size
  attach_vpc_config = false
  description       = var.description
  variables         = var.lambda_environment_variables
  providers = {
    aws = aws.east
  }
}


resource "aws_config_organization_custom_rule" "default" {
  name                = var.name
  trigger_types       = var.trigger_types
  lambda_function_arn = module.lambda.function.arn
  description         = var.description

  maximum_execution_frequency = contains(var.trigger_types, "ScheduledNotification") ? var.maximum_execution_frequency : null

  excluded_accounts = var.exclude_accounts
  input_parameters = jsonencode(merge(
    var.input_parameters,
    {
      "ExecutionRoleName" = var.org_lambda_cross_account_role_id
    }
  ))
}

resource "aws_config_organization_custom_rule" "default_east" {
  provider            = aws.east
  name                = var.name
  trigger_types       = var.trigger_types
  lambda_function_arn = module.lambda_east.function.arn
  description         = var.description

  maximum_execution_frequency = contains(var.trigger_types, "ScheduledNotification") ? var.maximum_execution_frequency : null
  excluded_accounts           = var.exclude_accounts
  input_parameters = jsonencode(merge(
    var.input_parameters,
    {
      "ExecutionRoleName" = var.org_lambda_cross_account_role_id
    }
  ))
}

output "rule" {
  value       = aws_config_organization_custom_rule.default
  description = "Organization custom rule object"
}

output "rule_east" {
  value       = aws_config_organization_custom_rule.default
  description = "Organization custom rule object (region: us-east-1)"
}
