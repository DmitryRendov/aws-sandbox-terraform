output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.main.arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_default_network_acl_id" {
  description = "The ID of the network ACL created by default on VPC creation"
  value       = aws_vpc.main.default_network_acl_id
}

output "vpc_default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = aws_vpc.main.default_security_group_id
}

output "vpc_default_route_table_id" {
  description = "The ID of the main route table associated with managed VPC"
  value       = aws_vpc.main.default_route_table_id
}

output "additional_cidr_blocks" {
  description = "A list of the additional IPv4 CIDR blocks associated with the VPC"
  value = [
    for i in aws_vpc_ipv4_cidr_block_association.main_vpc :
    i.cidr_block
  ]
}

output "additional_cidr_blocks_to_association_ids" {
  description = "A map of the additional IPv4 CIDR blocks to VPC CIDR association IDs"
  value = {
    for i in aws_vpc_ipv4_cidr_block_association.main_vpc :
    i.cidr_block => i.id
  }
}

output "igw_id" {
  value       = join("", aws_internet_gateway.main.*.id)
  description = "The ID of the Internet Gateway"
}