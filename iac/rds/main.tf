locals {
  prefix          = var.environment
  database_port   = 3306
  database_engine = "aurora-mysql"
}

resource "random_password" "password" {
  length  = 24
  special = false
}

resource "aws_rds_cluster" "main" {
  cluster_identifier            = var.cluster_identifier
  engine                        = local.database_engine
  replication_source_identifier = var.replication_source_identifier
  engine_version                = "5.7.mysql_aurora.2.10.1"
  database_name                 = var.database_name
  master_username               = var.database_user
  master_password               = random_password.password.result
  backup_retention_period       = 5 // Think about
  deletion_protection           = false
  skip_final_snapshot           = true
  storage_encrypted             = true
  db_subnet_group_name          = aws_db_subnet_group.main.name
  vpc_security_group_ids        = var.sg
  lifecycle {
    ignore_changes = [
      engine_version, // AWS may upgrade minor versions of the DB engine, adding this so we don't need to update our TF when that happens
    ]
  }
  tags = {
    Name        = "${local.prefix}-aurora-cluster"
    Environment = var.environment
  }
}

resource "aws_db_subnet_group" "main" {
  name_prefix = "${local.prefix}-subnet-group"
  description = "Isolated subnet group for ${local.prefix}"
  subnet_ids  = var.isolated_subnets.*.id
  tags = {
    Name        = "${local.prefix}-subnet-group"
    Environment = var.environment
  }
}

resource "aws_rds_cluster_instance" "aurora_db_instance" {
  count              = var.instance_count
  identifier         = "${var.cluster_identifier}-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = "db.t2.small"
  engine             = aws_rds_cluster.main.engine
  engine_version     = aws_rds_cluster.main.engine_version
  tags = {
    Name        = "${local.prefix}-aurora-db-instance"
    Environment = var.environment
  }
}

resource "aws_iam_role" "proxy_iam_role" {
  name = "${local.prefix}_proxy_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "rds.amazonaws.com"
        }
      },
    ]
  })
}

output "db_username" {
  value = aws_rds_cluster.main.master_username
}

output "db_host" {
  value = aws_rds_cluster.main.endpoint
}

output "db_name" {
  value = aws_rds_cluster.main.database_name
}

output "db_port" {
  value = aws_rds_cluster.main.port
}

output "db_password" {
  value = random_password.password.result
}