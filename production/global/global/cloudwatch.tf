###
# IAM role to support API Gateway and CloudWatch integration
###

resource "aws_api_gateway_account" "global_logs" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch.arn
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "api_gateway_cloudwatch" {
  name               = module.apigw_logs_label.id
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags               = module.apigw_logs_label.tags
}

resource "aws_iam_role_policy" "api_gateway_cloudwatch_role_policy" {
  name   = "${module.apigw_logs_label.id}-policy"
  role   = aws_iam_role.api_gateway_cloudwatch.id
  policy = data.aws_iam_policy_document.api_gateway_cloudwatch_policy.json
}

data "aws_iam_policy_document" "api_gateway_cloudwatch_policy" {

  statement {
    sid    = "APIGatewayCloudwatch"
    effect = "Allow"

    resources = [
      "*"
    ]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]
  }
}
