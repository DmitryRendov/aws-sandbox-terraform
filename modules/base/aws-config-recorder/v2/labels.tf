module "label" {
  source  = "../../../../modules/base/label/v1"
  context = var.label.context
}

module "config_label" {
  source     = "../../../../modules/base/label/v1"
  context    = var.label.context
  attributes = ["config", "recorder", data.aws_region.current.name]
}
