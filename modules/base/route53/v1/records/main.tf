locals {
  records = {
    for r in var.records :
    join("-", compact([r.name, r.type, lookup(r, "set_identifier", "")])) => r
  }
}

data "aws_route53_zone" "default" {
  zone_id      = var.zone_id
  name         = var.zone_name
  private_zone = var.private_zone
}

resource "aws_route53_record" "default" {
  for_each = local.records

  zone_id = data.aws_route53_zone.default.zone_id

  name                             = each.value.name != "" ? join(".", [each.value.name, data.aws_route53_zone.default.name]) : data.aws_route53_zone.default.name
  type                             = each.value.type
  ttl                              = lookup(each.value, "ttl", null)
  records                          = lookup(each.value, "records", null)
  set_identifier                   = lookup(each.value, "set_identifier", null)
  health_check_id                  = lookup(each.value, "health_check_id", null)
  multivalue_answer_routing_policy = lookup(each.value, "multivalue_answer_routing_policy", null)

  dynamic "alias" {
    for_each = length(keys(lookup(each.value, "alias", {}))) == 0 ? [] : [true]

    content {
      name                   = each.value.alias.name
      zone_id                = try(each.value.alias.zone_id, data.aws_route53_zone.default.zone_id)
      evaluate_target_health = lookup(each.value.alias, "evaluate_target_health", false)
    }
  }

  dynamic "failover_routing_policy" {
    for_each = length(keys(lookup(each.value, "failover_routing_policy", {}))) == 0 ? [] : [true]

    content {
      type = each.value.failover_routing_policy.type
    }
  }

  dynamic "geolocation_routing_policy" {
    for_each = length(keys(lookup(each.value, "geolocation_routing_policy", {}))) == 0 ? [] : [true]

    content {
      continent   = lookup(each.value.geolocation_routing_policy, "continent", null)
      country     = lookup(each.value.geolocation_routing_policy, "country", null)
      subdivision = lookup(each.value.geolocation_routing_policy, "subdivision", null)
    }
  }

  dynamic "latency_routing_policy" {
    for_each = length(keys(lookup(each.value, "latency_routing_policy", {}))) == 0 ? [] : [true]

    content {
      region = each.value.latency_routing_policy.region
    }
  }

  dynamic "weighted_routing_policy" {
    for_each = length(keys(lookup(each.value, "weighted_routing_policy", {}))) == 0 ? [] : [true]

    content {
      weight = each.value.weighted_routing_policy.weight
    }
  }
}
