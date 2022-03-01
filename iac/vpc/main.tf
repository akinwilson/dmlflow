resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "${var.name}-vpc-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_eip" "nat" {
  # elastic ips for nat of private subnets 
  count = length(var.private_subnets)
  vpc   = true
  tags = {
    Name        = "${var.name}-eip-${var.environment}-${format("%03d", count.index + 1)}"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name        = "${var.name}-igw-${var.environment}"
    Environment = var.environment
  }

}

resource "aws_nat_gateway" "main" {
  # we DO NOT give a gateway to the isolated subnets for aurora
  count         = length(var.private_subnets)
  allocation_id = element(aws_eip.nat.*.id, count.index)
  # subnet id in which to place gateway
  subnet_id = element(aws_subnet.public.*.id, count.index)
  tags = {
    Name        = "${var.name}-nat-${var.environment}-${format("%03d", count.index + 1)}"
    Environment = var.environment
  }
  depends_on = [aws_internet_gateway.main]
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.s3"
  tags = {
    Name        = "${var.name}-vpc-endpoint-s3-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_subnet" "isolated" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.isolated_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  count                   = length(var.isolated_subnets)
  map_public_ip_on_launch = false
  tags = {
    Name        = "${var.name}-isolated-subnet-${var.environment}-${format("%03d", count.index + 1)}"
    Environment = var.environment
  }

}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)
  count             = length(var.private_subnets)

  tags = {
    Name        = "${var.name}-private-subnet-${var.environment}-${format("%03d", count.index + 1)}"
    Environment = var.environment
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  count                   = length(var.public_subnets)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.name}-public-subnet-${var.environment}-${format("%03d", count.index + 1)}"
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
  route_table_id = element(aws_route_table.isolated.*.id, count.index)
}

resource "aws_flow_log" "main" {
  iam_role_arn    = aws_iam_role.vpc-flow-logs-role.arn
  log_destination = aws_cloudwatch_log_group.main.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
}

resource "aws_cloudwatch_log_group" "main" {
  name = "${var.name}-cloudwatch-log-group"
}

resource "aws_iam_role" "vpc-flow-logs-role" {
  name = "${var.name}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid    = "",
      Effect = "Allow",
      Action = "sts:AssumeRole",
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "vpc-flow-logs-policy" {
  name = "${var.name}-vpc-flow-logs-policy"
  role = aws_iam_role.vpc-flow-logs-role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
  ] })
}

output "id" {
  value = aws_vpc.main.id
}

output "private" {
  value = aws_subnet.private
}

output "public" {
  value = aws_subnet.public
}

output "isolated" {
  value = aws_subnet.isolated
}


