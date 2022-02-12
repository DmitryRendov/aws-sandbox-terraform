resource "aws_lb_target_group" "main" {
  for_each = local.tagret_groups

  name        = lookup(each.value, "name", null)
  name_prefix = lookup(each.value, "name_prefix", null)
  vpc_id      = var.vpc_id

  port             = lookup(each.value, "port", null)
  protocol         = lookup(each.value, "protocol", null) != null ? upper(each.value.protocol) : null
  protocol_version = lookup(each.value, "protocol_version", null) != null ? upper(each.value.protocol_version) : null
  target_type      = lookup(each.value, "target_type", null)

  deregistration_delay               = lookup(each.value, "deregistration_delay", null)
  slow_start                         = lookup(each.value, "slow_start", null)
  lambda_multi_value_headers_enabled = lookup(each.value, "lambda_multi_value_headers_enabled", false)
  load_balancing_algorithm_type      = lookup(each.value, "load_balancing_algorithm_type", null)

  dynamic "health_check" {
    for_each = length(keys(lookup(each.value, "health_check", {}))) == 0 ? [] : [each.value.health_check]

    content {
      enabled             = lookup(health_check.value, "enabled", length(keys(lookup(each.value, "health_check", {}))) > 0)
      interval            = lookup(health_check.value, "interval", null)
      path                = lookup(health_check.value, "path", null)
      port                = lookup(health_check.value, "port", null)
      healthy_threshold   = lookup(health_check.value, "healthy_threshold", null)
      unhealthy_threshold = lookup(health_check.value, "unhealthy_threshold", null)
      timeout             = lookup(health_check.value, "timeout", null)
      protocol            = lookup(health_check.value, "protocol", null)
      matcher             = lookup(health_check.value, "matcher", null)
    }
  }

  dynamic "stickiness" {
    for_each = length(keys(lookup(each.value, "stickiness", {}))) == 0 ? [] : [each.value.stickiness]

    content {
      enabled         = lookup(stickiness.value, "enabled", lookup(stickiness.value, "type", null) != null)
      cookie_duration = lookup(stickiness.value, "cookie_duration", null)
      type            = lookup(stickiness.value, "type", null)
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.label.tags,
    var.target_group_additional_tags
  )
}

resource "aws_lb_target_group_attachment" "main" {
  for_each = local.target_group_attachments != null ? local.target_group_attachments : {}

  target_group_arn  = aws_lb_target_group.main[each.value.tg_index].arn
  target_id         = each.value.target_id
  port              = lookup(each.value, "port", null)
  availability_zone = lookup(each.value, "availability_zone", null)
}
