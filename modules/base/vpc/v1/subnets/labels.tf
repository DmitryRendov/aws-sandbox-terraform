module "private_label" {
  source = "../../../../../modules/base/label/v1"

  context    = var.label.context
  attributes = ["private", "subnet"]
}

module "public_label" {
  source = "../../../../../modules/base/label/v1"

  context    = var.label.context
  attributes = ["public", "subnet"]
}

module "nat_label" {
  source = "../../../../../modules/base/label/v1"

  context    = var.label.context
  attributes = ["nat"]
}
