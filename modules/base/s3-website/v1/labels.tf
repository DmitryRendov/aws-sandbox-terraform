module "default_label" {
  source = "../../../../modules/base/label/v1"

  context    = var.label.context
  attributes = ["origin"]
  tags       = { "audit:public_access_ok" = local.public_access_ok }
}
