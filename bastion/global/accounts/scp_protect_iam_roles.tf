data "aws_iam_policy_document" "protect_iam_roles" {
  statement {
    sid    = "ProtectIAMRoles"
    effect = "Deny"
    not_actions = [
      "iam:GetContextKeysForPrincipalPolicy",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:ListRolePolicies",
      "iam:ListRoleTags"
    ]
    resources = var.protected_iam_roles
  }
}

resource "aws_organizations_policy" "protect_iam_roles" {
  name        = "ProtectIAMRoles"
  description = "Deny ability to modify IAM Roles"
  content     = data.aws_iam_policy_document.protect_iam_roles.json
}