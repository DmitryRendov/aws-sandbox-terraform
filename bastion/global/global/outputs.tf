output "sandbox_group" {
  description = "IAM Sandbox group"
  value       = aws_iam_group.sandbox
}

output "ops_group" {
  description = "IAM Ops group"
  value       = aws_iam_group.ops
}

output "developers_group" {
  description = "IAM Developers group"
  value       = aws_iam_group.developers
}

output "admin_username" {
  description = "IAM Admin username"
  value       = module.dmitry_rendov.name
}
