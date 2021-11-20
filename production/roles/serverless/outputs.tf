output "serverless_policy_arn" {
  description = "Production Serverless policy arn"
  value       = aws_iam_policy.serverless_policy.arn
}
