output "name_servers" {
  description = "Name servers of the Route53 zone"
  value       = module.hosted_zones.route53_zone_name_servers
}

output "zone_id" {
  description = "Zone ID of the Route53 zone"
  value       = join("", values(module.hosted_zones.route53_zone_zone_id))
}

output "zone_name" {
  description = "Name of the Route53 zone"
  value       = join("", values(module.hosted_zones.route53_zone_name))
}
