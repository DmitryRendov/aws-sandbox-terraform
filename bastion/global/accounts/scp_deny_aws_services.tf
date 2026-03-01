# Deny unexpected services
data "aws_iam_policy_document" "deny_aws_services" {
  statement {
    sid = "DenyAwsServices"

    not_actions = [
      "acm:*",
      "acm-pca:*",
      "cloudsearch:*",
      "apigateway:*",
      "apigateway:*",
      "application-autoscaling:*",
      "discovery:*",
      "athena:*",
      "autoscaling:*",
      "autoscaling-plans:*",
      "batch:*",
      "clouddirectory:*",
      "cloud9:*",
      "cloudformation:*",
      "cloudfront:*",
      "cloudtrail:*",
      "cloudwatch:*",
      "codebuild:*",
      "codecommit:*",
      "codedeploy:*",
      "codeguru-profiler:*",
      "codeguru-reviewer:*",
      "codepipeline:*",
      "codestar:*",
      "codestar-notifications:*",
      "comprehend:*",
      "config:*",
      "cognito-identity:*",
      "cognito-idp:*",
      "cognito-sync:*",
      "datapipeline:*",
      "dms:*",
      "ds:*",
      "dynamodb:*",
      "dax:*",
      "ebs:*",
      "ecr:*",
      "ecs:*",
      "elasticbeanstalk:*",
      "ec2:*",
      "eks:*",
      "elasticfilesystem:*",
      "elasticloadbalancing:*",
      "elasticmapreduce:*",
      "elastictranscoder:*",
      "elasticache:*",
      "es:*",
      "events:*",
      "firehose:*",
      "glue:*",
      "greengrass:*",
      "guardduty:*",
      "health:*",
      "iam:*",
      "inspector:*",
      "imagebuilder:*",
      "iot:*",
      "iotanalytics:*",
      "iot1click:*",
      "kafka:*",
      "kms:*",
      "kinesis:*",
      "kinesisvideo:*",
      "lambda:*",
      "lex:*",
      "machinelearning:*",
      "mgh:*",
      "opsworks:*",
      "opsworks-cm:*",
      "pi:*",
      "polly:*",
      "redshift:*",
      "rekognition:*",
      "rds:*",
      "rds-data:*",
      "rds-db:*",
      "resource-groups:*",
      "tag:*",
      "route53:*",
      "route53domains:*",
      "route53resolver:*",
      "s3:*",
      "secretsmanager:*",
      "securityhub:*",
      "ses:*",
      "sms:*",
      "sns:*",
      "sqs:*",
      "ssm:*",
      "sso:*",
      "states:*",
      "sts:*",
      "textract:*",
      "transcribe:*",
      "translate:*",
      "waf:*",
      "waf-regional:*",
      "xray:*",
    ]

    resources = ["*"]

    effect = "Deny"

    condition {
      test     = "StringNotLike"
      variable = "aws:PrincipalARN"

      values = [
        "arn:aws:iam::*:role/super-user"
      ]
    }

  }
}

