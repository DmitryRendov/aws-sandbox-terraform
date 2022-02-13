locals {
  zone_name                         = var.zone_name == "" ? "${var.domain_name}." : var.zone_name
  process_domain_validation_options = var.process_domain_validation_options && var.validation_method == "DNS"
  domain_validation_options         = local.process_domain_validation_options ? aws_acm_certificate.default.domain_validation_options : toset([])
}

