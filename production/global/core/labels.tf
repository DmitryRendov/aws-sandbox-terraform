module "label" {
  source      = "../../../modules/base/label/v1"
  environment = terraform.workspace
  name        = local.role_name
  team        = local.team
}
