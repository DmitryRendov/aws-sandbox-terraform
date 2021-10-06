module "label" {
  source      = "../../../modules/base/label/v1"
  environment = "audit"
  name        = local.role_name
  team        = local.team
}

module "reporter_lambda_label" {
  source     = "../../../modules/base/label/v1"
  context    = module.label.context
  attributes = ["reporter"]
}

module "reporter_lambda_cross_account_label" {
  source     = "../../../modules/base/label/v1"
  context    = module.label.context
  attributes = ["reporter", "cross", "account"]
}

module "aggregator_role_label" {
  source     = "../../../modules/base/label/v1"
  context    = module.label.context
  attributes = ["org", "role"]
}

module "org_lambda_role_label" {
  source     = "../../../modules/base/label/v1"
  context    = module.label.context
  attributes = ["org", "lambda", "role"]
}

module "org_lambda_cross_account_role_label" {
  source     = "../../../modules/base/label/v1"
  context    = module.label.context
  attributes = ["org", "cross", "account", "role"]
}
