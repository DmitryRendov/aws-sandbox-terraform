locals {
  use_existing_eips       = length(var.external_nat_ips) > 0
  nat_gateways_count      = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(var.azs) : length(var.private_subnets)
  nat_gateways_eip_count  = local.use_existing_eips ? 0 : local.nat_gateways_count
  gateway_eip_allocations = local.use_existing_eips ? data.aws_eip.nat_ips.*.id : aws_eip.nat.*.id
}

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? local.nat_gateways_eip_count : 0

  vpc = true

  tags = var.nat_label.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "public" {
  count = var.enable_nat_gateway ? local.nat_gateways_count : 0

  allocation_id = element(
    local.gateway_eip_allocations,
    var.single_nat_gateway ? 0 : count.index,
  )
  subnet_id = element(
    aws_subnet.public.*.id,
    var.single_nat_gateway ? 0 : count.index,
  )

  tags = merge(var.nat_label.tags,
    {
      "Name" = var.single_nat_gateway ? var.nat_label.id : format("%s-%s", var.nat_label.id, element(var.azs, count.index))
    }
  )
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route" "nat_gateway" {
  count = var.enable_nat_gateway ? local.nat_gateways_count : 0

  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.public.*.id, count.index)
}
