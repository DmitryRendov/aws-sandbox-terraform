module "label" {
  source      = "../../../modules/base/null-label/v2"
  environment = "audit"
  role_name   = "global"
}

module "aws_config_label" {
  source      = "../../../modules/base/null-label/v2"
  environment = "mob"
  role_name   = "global"
  attributes  = ["aws", "config"]
}
