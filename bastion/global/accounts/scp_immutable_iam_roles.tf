# Prevent IAM users and roles from making specified changes,
# with an exception for a specified super-user role
data "aws_iam_policy_document" "immutable_admin_role" {
  statement {
    sid = "ImmutableAdminRole"

    actions = [
      "iam:AttachRolePolicy",
      "iam:DeleteRole",
      "iam:DeleteRolePermissionsBoundary",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePermissionsBoundary",
      "iam:PutRolePolicy",
      "iam:UpdateAssumeRolePolicy",
      "iam:UpdateRole",
      "iam:UpdateRoleDescription",
    ]

    resources = [
      "arn:aws:iam::*:role/super-user"
    ]

    condition {
      test     = "StringNotLike"
      variable = "aws:PrincipalARN"
      values = [
        "arn:aws:iam::*:role/super-user"
      ]
    }

    effect = "Deny"

  }
}

