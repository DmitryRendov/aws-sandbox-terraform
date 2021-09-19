##
# ORG Custom Config Rule to ensures S3 Buckets have server side encryption enabled.
# With an exception, if we have a proper tag is set, eg `audit:public_okay`
#
data "aws_region" "current" {}

locals {
  lambda_function_id = length(module.lambda_label.id) > 64 ? module.lambda_label.id_brief : module.lambda_label.id
}

module "lambda_label" {
  source      = "../../../../../modules/base/null-label/v2"
  environment = "audit"
  role_name   = "aws-config"
  attributes  = ["s3", "encryption", data.aws_region.current.name]
}

data "aws_iam_role" "org_lambda_role" {
  name = var.org_lambda_role_id
}

resource "aws_iam_policy" "lambda_policy" {
  name   = module.lambda_label.id
  path   = "/"
  policy = data.aws_iam_policy_document.lambda_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = var.org_lambda_cross_account_role_id
  policy_arn = aws_iam_policy.lambda_policy.arn
}

data "aws_iam_policy_document" "lambda_policy_doc" {
  statement {
    sid = "S3GetEncryptionConfiguration"
    actions = [
      "s3:GetEncryptionConfiguration",
    ]
    effect    = "Allow"
    resources = ["arn:aws:s3:::*"]
  }
  statement {
    sid = "Config"
    actions = [
      "config:GetComplianceDetailsByConfigRule",
      "config:GetResourceConfigHistory",
      "config:PutEvaluations",
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    sid = "AllowAccessToCloudwatchLogs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }
}

// TODO: Move source code to S3 bucket and CircleCI
data "archive_file" "lambda_package" {
  type        = "zip"
  source_file = "${path.module}/files/s3_bucket_encryption_custom/s3_bucket_encryption_custom.py"
  output_path = "${path.module}/files/s3_bucket_encryption_custom.zip"
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
  handler          = "s3_bucket_encryption_custom.lambda_handler"
  memory_size      = 128
  source_code_hash = data.archive_file.lambda_package.output_base64sha256
  runtime          = "python3.8"
  timeout          = 60
  description      = "Lambda for Custom Config Rule to ensures S3 Buckets have server side encryption enabled."

  environment {
    variables = {
      "LOG_LEVEL" = "INFO"
    }
  }

  lifecycle {
    ignore_changes = [last_modified]
  }
}


resource "aws_config_organization_custom_rule" "s3_bucket_encryption_custom" {
  depends_on = [
    aws_lambda_function.default
  ]
  name                = "s3_bucket_encryption_custom"
  trigger_types       = ["ConfigurationItemChangeNotification"]
  lambda_function_arn = aws_lambda_function.default.arn
  description         = "Config Rule to ensures S3 Buckets have server side encryption enabled, except tagged by `audit:public_okay` tag."

  excluded_accounts = var.exclude_accounts
  input_parameters = jsonencode(merge(
    var.input_parameters,
    {
      "ExecutionRoleName" = var.org_lambda_cross_account_role_id
    }
  ))
}
