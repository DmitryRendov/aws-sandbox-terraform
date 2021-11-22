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
