module "atlantis" {
  source         = "../../../modules/base/ecr/v1"
  label          = module.label
  name           = "atlantis"
  cross_accounts = [var.aws_account_map["production"]]
}
