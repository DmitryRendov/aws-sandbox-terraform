resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = var.label.tags
}

resource "aws_vpc_ipv4_cidr_block_association" "main_vpc" {
  for_each = length(var.secondary_cidr_blocks) > 0 ? toset(var.secondary_cidr_blocks) : []

  vpc_id     = aws_vpc.main.id
  cidr_block = each.value
}

resource "aws_internet_gateway" "main" {
  count = var.create_igw ? 1 : 0

  vpc_id = aws_vpc.main.id

  tags = module.vpc_label.tags
}
