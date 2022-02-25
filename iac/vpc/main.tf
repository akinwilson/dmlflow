resource "aws_vpc" "main" {
    cidr_block = var.cidr
    enable_dns_hostnames = true
    enable_dns_support = true
    tags {
        Name = "${var.name}-vpc-${var.environment}"
        Environment = var.environment
    }
}



resource "aws_subnet" "isolated" {
  vpc_id = aws_vpc.main.id
  cidr_block              = element(var.isolated_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  count                   = length(var.isolated_subnets)
  map_public_ip_on_launch = false 
  tags = {
    Name        = "${var.name}-isolated-subnet-${var.environment}-${format("%03d", count.index + 1)}"
    Environment = var.environment
  }

}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.name}-routing-table-public"
    Environment = var.environment
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.main.id
  tags = {
    Name        = "${var.name}-routing-table-private-${format("%03d", count.index + 1)}"
    Environment = var.environment
  }
}

resource "aws_route" "private" {
  count                  = length(compact(var.private_subnets))
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.main.*.id, count.index)
}

resource "aws_route_table" "isolated" {
  count  = length(var.isolated_subnets)
  vpc_id = aws_vpc.main.id
  tags = {
    Name        = "${var.name}-routing-table-isolated-${format("%03d", count.index + 1)}"
    Environment = var.environment
  }
}
resource "aws_route" "isolated" {
  count                  = length(compact(var.isolated_subnets))
  route_table_id         = element(aws_route_table.isolated.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.main.*.id, count.index)
}


resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "isolated" {
  count          = length(var.isolated_subnets)
  subnet_id      = element(aws_subnet.isolated.*.id, count.index)
  route_table_id = aws_route_table.isolated.id
}

