resource "aws_vpc" "main" {
    cidr_block = var.cidr
    enable_dns_hostnames = true
    enable_dns_support = true
    tags {
        Name = "${var.name}-vpc-${var.environment}"
        Environment = var.environment
    }
}

