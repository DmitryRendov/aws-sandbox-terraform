module "label" {
  source      = "../../../modules/base/label/v1"
  team        = local.team
  name        = local.role_name
  environment = local.account_name
}
