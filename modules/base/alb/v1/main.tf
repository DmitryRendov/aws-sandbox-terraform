resource "aws_lb" "main" {
  name        = var.use_name_prefix ? null : var.name
  name_prefix = var.use_name_prefix ? "${var.name}-" : null

  internal           = var.internal
  load_balancer_type = var.load_balancer_type
  ip_address_type    = var.ip_address_type

  security_groups = var.security_group_ids
  subnets         = var.subnet_ids

  enable_http2               = var.http2_enabled
  idle_timeout               = var.idle_timeout
  drop_invalid_header_fields = var.drop_invalid_header_fields

  enable_deletion_protection = var.deletion_protection_enabled

  dynamic "access_logs" {
    for_each = var.access_logs == null ? [] : [var.access_logs]

    content {
      enabled = lookup(access_logs.value, "enabled", lookup(access_logs.value, "bucket", null) != null)
      bucket  = lookup(access_logs.value, "bucket", null)
      prefix  = lookup(access_logs.value, "prefix", null)
    }
  }

  tags = var.label.tags
}
