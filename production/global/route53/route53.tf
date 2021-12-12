module "hosted_zones" {
  source = "../../../modules/base/route53/v1/zones"
  zones = [
    {
      domain_name = local.domain_name
    }
  ]
  label = module.label
}
