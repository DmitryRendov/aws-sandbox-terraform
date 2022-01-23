module "alb_label" {
  source      = "../../../modules/base/label/v1"
  environment = local.account_name
  name        = local.role_name
  team        = local.team
  attributes  = ["alb"]
}
