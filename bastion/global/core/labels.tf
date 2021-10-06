module "label" {
  source      = "../../../modules/base/label/v1"
  environment = terraform.workspace
  name        = local.role_name
  team        = local.team
}

module "budget_label" {
  source     = "../../../modules/base/label/v1"
  context    = module.label.context
  attributes = ["budget"]
}
