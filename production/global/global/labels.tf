module "label" {
  source      = "../../../modules/base/label/v1"
  environment = local.account_name
  name        = local.role_name
  team        = local.team
}

module "apigw_logs_label" {
  source     = "../../../modules/base/label/v1"
  context    = module.label.context
  attributes = ["apigateway", "cloudwatch"]
}
