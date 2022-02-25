resource "aws_security_group" "rds" {
    name   = "${var.name}-sg-rds-${var.environment}"
    vpc_id = var.vpc_id
    ingress {
        protocol         = "-1"
        description = "port of mysql server"
        from_port        = 3306
        to_port          = 3306
        cidr_blocks      = ["10.0.0.0/20"]
    }
    egress {
        protocol         = "-1"
        from_port        = 0
        to_port          = 0
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    tags = {
        Name        = "${var.name}-sg-rds-${var.environment}"
        Environment = var.environment
    }
}


output rds {
    value = aws_security_group.rds
}