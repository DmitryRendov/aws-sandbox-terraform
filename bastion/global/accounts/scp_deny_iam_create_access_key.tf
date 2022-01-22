# Deny ability to create IAM access keys unless it's a superuser
data "aws_iam_policy_document" "deny_iam_create_access_key" {
  statement {
    sid = "DenyIamCreateAccessKey"

    actions = [
      "iam:CreateAccessKey"
    ]

    resources = [
      "*"
    ]

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

