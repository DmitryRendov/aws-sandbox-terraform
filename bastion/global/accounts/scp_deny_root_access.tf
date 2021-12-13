data "aws_iam_policy_document" "deny_root_access" {
  statement {
    sid       = "DenyRootAccess"
    actions   = ["*"]
    resources = ["*"]
    effect    = "Deny"
    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:root"]
    }
  }
}

