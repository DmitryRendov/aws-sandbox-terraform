module "vpc_label" {
  source      = "../../../modules/base/label/v1"
  team        = local.team
  name        = local.role_name
  environment = local.account_name
  attributes  = ["vpc"]
}

module "private_label" {
  source      = "../../../modules/base/label/v1"
  team        = local.team
  name        = local.role_name
  environment = local.account_name
  attributes  = ["private", "subnet"]
}

module "public_label" {
  source      = "../../../modules/base/label/v1"
  team        = local.team
  name        = local.role_name
  environment = local.account_name
  attributes  = ["public", "subnet"]
}

module "nat_label" {
  source      = "../../../modules/base/label/v1"
  team        = local.team
  name        = local.role_name
  environment = local.account_name
  attributes  = ["nat"]
}
