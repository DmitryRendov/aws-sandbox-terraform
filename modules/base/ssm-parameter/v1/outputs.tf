output "parameter" {
  description = "The SSM Parameter resource managed by this role"
  value       = local.is_secret_string ? aws_ssm_parameter.default_secure_string[0] : aws_ssm_parameter.default_string[0]
}
