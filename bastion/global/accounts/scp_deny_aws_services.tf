# Deny expensive/unexpected services
data "aws_iam_policy_document" "deny_aws_services" {
  statement {
    sid = "DenyAwsServices"

    actions = [
      "*"
    ]

    resources = [
      "a4b:*",
      "athena:*",
      "eks:*",
      "elasticmapreduce:*",
      "elasticache:*",
      "cassandra:*",
      "kinesis:*",
      "kinesisanalytics:*",
      "kinesisvideo:*"
    ]

    effect = "Deny"

  }
}

