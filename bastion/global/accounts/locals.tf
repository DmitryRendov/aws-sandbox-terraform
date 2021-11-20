locals {
  team      = "ops"
  role_name = "accounts"

  email = join("@", ["drendov", "gmail.com"])
}

locals {
  root_scp_policies = [
    aws_organizations_policy.deny_disallowed_regions.id,
    aws_organizations_policy.immutable_admin_role.id,
    aws_organizations_policy.protect_iam_roles.id,
    aws_organizations_policy.deny_root_access.id,
  ]
}