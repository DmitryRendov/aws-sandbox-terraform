######
# IAM role and permissions to perform Serverless deployments
###

data "aws_iam_policy_document" "serverless_policy_doc" {
  statement {
    effect = "Allow"

    actions = [
      "s3:ListAllMyBuckets",
      "cloudformation:Describe*",
      "cloudformation:List*",
      "cloudformation:Get*",
      "cloudformation:ValidateTemplate",
      "lambda:Get*",
      "lambda:List*",
      "lambda:CreateEventSourceMapping",
      "lambda:UpdateEventSourceMapping",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "cloudformation:CreateStack",
      "cloudformation:UpdateStack",
      "cloudformation:DeleteStack",
      "cloudformation:CancelUpdateStack",
      "cloudformation:ContinueUpdateRollback",
      "cloudformation:CreateChangeSet",
      "cloudformation:CreateUploadBucket",
      "cloudformation:EstimateTemplateCost",
      "cloudformation:ExecuteChangeSet",
      "cloudformation:UpdateTerminationProtection",
    ]

    resources = [
      "arn:aws:cloudformation:${var.region}:${local.aws_account_id}:stack/aws-sandbox-serverless*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "lambda:AddPermission",
      "lambda:CreateFunction",
      "lambda:CreateAlias",
      "lambda:DeleteAlias",
      "lambda:DeleteFunction",
      "lambda:InvokeFunction",
      "lambda:PublishVersion",
      "lambda:RemovePermission",
      "lambda:Update*",
      "lambda:PutFunctionConcurrency",
    ]

    resources = [
      "arn:aws:lambda:${var.region}:${local.aws_account_id}:function:aws-sandbox-serverless*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "apigateway:GET",
      "apigateway:POST",
      "apigateway:PUT",
      "apigateway:DELETE",
      "apigateway:PATCH",
      "apigateway:UpdateRestApiPolicy",
    ]

    resources = [
      "arn:aws:apigateway:${var.region}:*:/restapis",
      "arn:aws:apigateway:${var.region}:*:/restapis/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "iam:PassRole",
      "iam:CreateServiceLinkedRole",
      "iam:GetServiceLinkedRoleDeletionStatus",
      "iam:DeleteServiceLinkedRole",
    ]

    resources = [
      "arn:aws:iam::${local.aws_account_id}:role/${module.label.id}*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:FilterLogEvents",
      "logs:GetLogEvents",
      "logs:PutSubscriptionFilter",
      "logs:DeleteRetentionPolicy",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:${var.region}:${local.aws_account_id}:log-group:/aws/lambda/aws-sandbox-serverless*:*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "s3:GetBucketVersioning",
      "s3:PutBucketVersioning",
      "s3:GetBucketLocation",
      "s3:PutBucketPolicy",
      "s3:GetBucketWebsite",
      "s3:PutBucketWebsite",
      "s3:DeleteBucketWebsite",
    ]

    resources = [
      module.serverless_lambdas.arn,
      "${module.serverless_lambdas.arn}/*",
    ]
  }
}

resource "aws_iam_policy" "serverless_policy" {
  name   = "${module.label.id}-policy"
  policy = data.aws_iam_policy_document.serverless_policy_doc.json
}

module "serverless_service_role" {
  source   = "../../../modules/base/iam-service-role/v1"
  services = ["lambda.amazonaws.com"]
  label    = module.label
}

resource "aws_iam_role_policy_attachment" "serverless_policy_attachemnt" {
  role       = module.serverless_service_role.name
  policy_arn = aws_iam_policy.serverless_policy.arn
}
