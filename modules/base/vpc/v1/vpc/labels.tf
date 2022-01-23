module "vpc_label" {
  source = "../../../../../modules/base/label/v1"

  context    = var.label.context
  attributes = ["vpc"]
}
