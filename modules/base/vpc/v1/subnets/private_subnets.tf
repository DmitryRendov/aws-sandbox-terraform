resource "aws_subnet" "private" {
  count = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  vpc_id               = data.aws_vpc.default.id
  cidr_block           = element(concat(var.private_subnets, [""]), count.index)
  availability_zone    = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null

  tags = merge(module.private_label.tags,
    {
      "Name" = format("%s-%s", module.private_label.id, element(var.azs, count.index))
    }
  )
}

resource "aws_route_table" "private" {
  count = length(var.private_subnets) > 0 ? local.nat_gateways_count : 0

  vpc_id = data.aws_vpc.default.id

  tags = module.private_label.tags
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, var.single_nat_gateway ? 0 : count.index)
}
