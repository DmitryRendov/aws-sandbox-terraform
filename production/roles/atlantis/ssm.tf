module "github_token" {
  source      = "../../../modules/base/ssm-parameter/v1"
  label       = module.label
  description = "GitHub Token"
  secret_name = "github_token"
  type        = "SecureString"
}

module "github_webhook_secret" {
  source      = "../../../modules/base/ssm-parameter/v1"
  label       = module.label
  description = "GitHub Webhook Secret"
  secret_name = "github_webhook_secret"
  type        = "SecureString"
}
