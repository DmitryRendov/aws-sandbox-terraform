output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private.*.id
}

output "private_subnet_arns" {
  description = "List of ARNs of private subnets"
  value       = aws_subnet.private.*.arn
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = aws_subnet.private.*.cidr_block
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public.*.id
}

output "public_subnet_arns" {
  description = "List of ARNs of public subnets"
  value       = aws_subnet.public.*.arn
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = aws_subnet.public.*.cidr_block
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways created"
  value       = aws_nat_gateway.public.*.id
}

output "nat_gateway_public_ips" {
  description = "EIP of the NAT Gateway"
  value       = aws_eip.nat.*.public_ip
}

output "azs" {
  description = "A list of availability zones specified as argument to this module"
  value       = var.azs
}

output "nat_ips" {
  description = "IP Addresses in use for NAT"
  value       = coalescelist(aws_eip.nat.*.public_ip, data.aws_eip.nat_ips.*.public_ip, tolist([""]))
}
