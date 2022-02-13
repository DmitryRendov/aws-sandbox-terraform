module "label" {
  source              = "../../../base/label/v1"
  context             = var.label.context
  attributes          = [var.secret_name]
  delimiter           = "/"
  regex_replace_chars = "/[^-_a-zA-Z0-9/]/"
}

resource "aws_ssm_parameter" "default_secure_string" {
  count       = local.is_secret_string ? 1 : 0
  name        = "/${module.label.id}"
  description = var.description
  type        = var.type
  value       = "not_secret"
  overwrite   = true
  tier        = var.tier
  tags        = local.tags

  lifecycle {
    ignore_changes = [value, tier]
  }
}

resource "aws_ssm_parameter" "default_string" {
  count       = local.is_string ? 1 : 0
  name        = "/${module.label.id}"
  description = var.description
  type        = var.type
  value       = var.value
  overwrite   = true
  tier        = var.tier
  tags        = local.tags
}
