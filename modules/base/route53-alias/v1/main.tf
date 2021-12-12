data "aws_route53_zone" "default" {
  zone_id      = var.parent_zone_id
  private_zone = var.private_zone
}

resource "aws_route53_record" "default" {
  count   = length(compact(var.aliases))
  zone_id = data.aws_route53_zone.default.zone_id
  name    = element(compact(var.aliases), count.index)
  type    = "A"

  alias {
    name                   = var.target_dns_name
    zone_id                = var.target_zone_id
    evaluate_target_health = var.evaluate_target_health
  }
}
