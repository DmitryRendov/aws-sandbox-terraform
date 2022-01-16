data "aws_iam_policy_document" "security_settings" {
  statement {
    sid = "DenyDeleteAccessAnalyzer"
    actions = [
      "access-analyzer:DeleteAnalyzer"
    ]
    resources = ["*"]
    effect    = "Deny"
  }

  statement {
    sid = "DenyCreateEBSWithoutEncryption"
    actions = [
      "ec2:CreateVolume"
    ]
    resources = ["*"]
    effect    = "Deny"
    condition {
      test     = "Bool"
      variable = "ec2:Encrypted"
      values   = ["false"]
    }
  }

  statement {
    sid = "PreventModifyingS3PublicAccessBlock"
    actions = [
      "s3:PutBucketPublicAccessBlock"
    ]
    resources = ["*"]
    effect    = "Deny"
  }
}
