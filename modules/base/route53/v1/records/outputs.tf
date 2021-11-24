output "route53_record_fqdn" {
  description = "FQDN built using the zone domain and name"
  value       = { for k, v in aws_route53_record.default : k => v.fqdn }
}
