output "nameservers" {
  value = module.hosted_zones.route53_zone_name_servers
}
