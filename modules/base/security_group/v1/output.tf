output "security_group_id" {
  value       = aws_security_group.this.id
  description = "Security Group ID"
}

output "security_group_arn" {
  value       = aws_security_group.this.arn
  description = "ARN of the security group."
}

output "security_group_vpc_id" {
  description = "The VPC ID"
  value       = aws_security_group.this.vpc_id
}

output "security_group_owner_id" {
  description = "The Owner ID"
  value       = aws_security_group.this.owner_id
}

output "security_group_name" {
  description = "The name of the security group"
  value       = aws_security_group.this.name
}

output "ingress_rules" {
  value       = aws_security_group.this.ingress
  description = "All your ingress rules."
}

output "egress_rules" {
  value       = aws_security_group.this.egress
  description = "All your egress rules."
}
