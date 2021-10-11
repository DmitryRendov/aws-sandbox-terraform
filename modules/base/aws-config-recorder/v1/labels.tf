module "label" {
  source      = "../../label/v1"
  environment = var.environment
  name        = var.role_name
}

module "config_label" {
  source     = "../../label/v1"
  context    = module.label.context
  attributes = ["config", "recorder", data.aws_region.current.name]
}
