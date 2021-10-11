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

module "audit" {
  source = "../../../modules/base/aws-organization-account/v2"
  name   = "audit"
  scp_policies = [
    aws_organizations_policy.deny_disallowed_regions.id,
    aws_organizations_policy.immutable_admin_role.id,
  ]
}

module "bastion" {
  source = "../../../modules/base/aws-organization-account/v2"
  name   = "bastion"
  email  = local.email
  scp_policies = [
    aws_organizations_policy.deny_disallowed_regions.id,
    aws_organizations_policy.immutable_admin_role.id,
  ]
}

module "production" {
  source = "../../../modules/base/aws-organization-account/v2"
  name   = "production"
  scp_policies = [
    aws_organizations_policy.deny_disallowed_regions.id,
    aws_organizations_policy.immutable_admin_role.id,
  ]
}

output "account_ids" {
  value = {
    "audit"      = module.audit.account_id
    "bastion"    = module.bastion.account_id
    "production" = module.production.account_id
  }
}
