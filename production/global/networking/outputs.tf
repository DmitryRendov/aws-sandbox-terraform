output "vpc_id" {
    value = module.vpc.vpc_id
}

output "public_subnet_ids" {
    value = module.subnets.public_subnets
}

output "private_subnet_ids" {
    value = module.subnets.private_subnets
}