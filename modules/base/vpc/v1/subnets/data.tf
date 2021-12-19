# Get object aws_vpc by vpc_id
data "aws_vpc" "default" {
  id = var.vpc_id
}

data "aws_eip" "nat_ips" {
  count     = length(var.external_nat_ips)
  public_ip = element(var.external_nat_ips, count.index)
}
