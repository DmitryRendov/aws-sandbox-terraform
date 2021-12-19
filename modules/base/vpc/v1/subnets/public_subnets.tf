resource "aws_subnet" "public" {
  count = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  vpc_id                  = data.aws_vpc.default.id
  cidr_block              = element(concat(var.public_subnets, [""]), count.index)
  availability_zone       = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id    = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = var.public_label.tags
}

resource "aws_route_table" "public" {
  count  = length(var.vpc_default_route_table_id) > 0 ? 0 : 1
  vpc_id = data.aws_vpc.default.id

  tags = merge(var.public_label.tags,
    {
      "Name" = format("%s-%s", var.public_label.id, element(var.azs, count.index))
    }
  )
}

resource "aws_route" "public" {
  count                  = length(var.vpc_default_route_table_id) > 0 ? 0 : 1
  route_table_id         = join("", aws_route_table.public.*.id)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.igw_id
}

resource "aws_route_table_association" "public" {
  count          = length(var.vpc_default_route_table_id) > 0 ? 0 : length(var.public_subnets)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "public_default" {
  count          = length(var.vpc_default_route_table_id) > 0 ? length(var.public_subnets) : 0
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = var.vpc_default_route_table_id
}
