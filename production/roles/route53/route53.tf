module "hosted_zones" {
  source = "../../../modules/base/route53/v1/zones"
  zones = [
    {
      domain_name = "xn--b1add1bfm.xn--90ais" // "девопc.бел"
    }
  ]
  shared_tags = module.label.tags
}
