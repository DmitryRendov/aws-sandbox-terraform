resource "aws_organizations_organization" "mob" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "config-multiaccountsetup.amazonaws.com",
    "securityhub.amazonaws.com",
    "sso.amazonaws.com",
  ]

  enabled_policy_types = ["SERVICE_CONTROL_POLICY"]
  feature_set          = "ALL"
}

output "org" {
  value = aws_organizations_organization.mob
}

locals {
  root_scp_policies = [
    aws_organizations_policy.deny_disallowed_regions.id,
    aws_organizations_policy.immutable_admin_role.id,
    aws_organizations_policy.protect_iam_roles.id,
    aws_organizations_policy.deny_root_access.id,
  ]
}

resource "aws_organizations_policy_attachment" "root_scp_policies" {
  count     = length(local.root_scp_policies)
  policy_id = element(local.root_scp_policies, count.index)
  target_id = aws_organizations_organization.mob.roots[0].id
}

module "audit" {
  source       = "../../../modules/base/aws-organization-account/v2"
  name         = "audit"
  scp_policies = [] // Unique account SCPs can be added here
}

module "bastion" {
  source = "../../../modules/base/aws-organization-account/v2"
  name   = "bastion"
  email  = local.email
  // SCPs don't affect users or roles in the management account
}

module "production" {
  source       = "../../../modules/base/aws-organization-account/v2"
  name         = "production"
  scp_policies = [] // Unique account SCPs can be added here
}

output "account_ids" {
  value = {
    "audit"      = module.audit.account_id
    "bastion"    = module.bastion.account_id
    "production" = module.production.account_id
  }
}
