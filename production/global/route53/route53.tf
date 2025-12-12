module "hosted_zones" {
  source = "../../../modules/base/route53/v1/zones"
  zones = [
    {
      domain_name = local.domain_name
    }
  ]
  label = module.label
}

module "acm_request_certificate" {
  source                    = "../../../modules/base/acm/v1"
  domain_name               = local.domain_name
  subject_alternative_names = ["*.${local.domain_name}"]
  zone_name                 = module.hosted_zones.route53_zone_name[local.domain_name]
  label                     = module.label
}
