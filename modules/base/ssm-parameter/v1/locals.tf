locals {
  secret_tag       = var.type == "SecureString"
  is_secret_string = var.type == "SecureString"
  is_string        = var.type == "String"
  tags             = merge(module.label.tags, { "username" : var.username, "secret" : local.secret_tag })
}
