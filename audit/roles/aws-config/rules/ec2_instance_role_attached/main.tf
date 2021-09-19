##
# ORG Custom Config Rule to check whether EC2 Instance have IAM instance role attached.
#
data "aws_region" "current" {}

locals {
  lambda_function_id = length(module.lambda_label.id) > 64 ? module.lambda_label.id_brief : module.lambda_label.id
}

module "lambda_label" {
  source      = "../../../../../modules/base/null-label/v2"
  environment = "audit"
  role_name   = "aws-config"
  attributes  = ["ec2", "role", "attached", data.aws_region.current.name]
}

data "aws_iam_role" "org_lambda_role" {
  name = var.org_lambda_role_id
}

data "archive_file" "lambda_package" {
  type        = "zip"
  source_file = "${path.module}/files/ec2_instance_role_attached/ec2_instance_role_attached.py"
  output_path = "${path.module}/files/ec2_instance_role_attached.zip"
}

resource "aws_lambda_permission" "lambda_permission" {
  count          = length(var.aws_account_ids)
  statement_id   = "AllowExecutionFromCrossAccount-${element(var.aws_account_ids, count.index)}"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.default.function_name
  principal      = "config.amazonaws.com"
  source_account = element(sort(var.aws_account_ids), count.index)
}

resource "aws_lambda_function" "default" {
  filename         = data.archive_file.lambda_package.output_path
  function_name    = local.lambda_function_id
  role             = data.aws_iam_role.org_lambda_role.arn
  handler          = "ec2_instance_role_attached.lambda_handler"
  memory_size      = 128
  source_code_hash = data.archive_file.lambda_package.output_base64sha256
  runtime          = "python3.8"
  timeout          = 60
  description      = "Lambda to checks whether EC2 instances have instance role attached."

  environment {
    variables = {
      "LOG_LEVEL" = "INFO"
    }
  }

  lifecycle {
    ignore_changes = [last_modified]
  }
}

resource "aws_config_organization_custom_rule" "ec2_instance_role_attached" {
  depends_on = [
    aws_lambda_function.default
  ]
  name                = "ec2_instance_role_attached"
  trigger_types       = ["ScheduledNotification"]
  lambda_function_arn = aws_lambda_function.default.arn
  description         = "Checks whether EC2 instance have instance role attached."

  maximum_execution_frequency = var.maximum_execution_frequency
  excluded_accounts           = var.exclude_accounts
  input_parameters = jsonencode(merge(
    var.input_parameters,
    {
      "ExecutionRoleName" = var.org_lambda_cross_account_role_id
    }
  ))
}
