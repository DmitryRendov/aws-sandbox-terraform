module "label" {
  source      = "../../../modules/base/label/v1"
  environment = "audit"
  name        = "sandbox"
  team        = local.team
}

module "aws_config_label" {
  source     = "../../../modules/base/label/v1"
  context    = module.label.context
  attributes = ["aws", "config"]
}
