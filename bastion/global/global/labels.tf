module "label" {
  source      = "../../../modules/base/label/v1"
  environment = terraform.workspace
  name        = local.role_name
  team        = local.team
}

module "developer_label" {
  source      = "../../../modules/base/label/v1"
  context     = module.label.context
  environment = "production"
  name        = "developer"
  attributes  = ["policy"]
}

module "backups_label" {
  source     = "../../../modules/base/label/v1"
  context    = module.label.context
  attributes = ["backups"]
}

module "deactivated_label" {
  source     = "../../../modules/base/label/v1"
  context    = module.label.context
  attributes = ["deactivated"]
}
