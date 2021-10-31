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

resource "aws_organizations_policy" "deny_root_access" {
  name        = "DenyRootAccess"
  description = "Deny the root user from taking any action"
  content     = data.aws_iam_policy_document.deny_root_access.json
}
