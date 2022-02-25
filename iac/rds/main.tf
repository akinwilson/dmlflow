locals {
  prefix          = "${var.environment}-${var.cluster_identifier}"
  database_port   = 3306
  database_engine = "aurora-mysql"
}

resource "random_password" "password" {
  length  = 24
  special = false
}

resource "aws_rds_cluster" "aurora_db" {
  cluster_identifier            = var.cluster_identifier
  engine                        = local.database_engine
  replication_source_identifier = var.replication_source_identifier
  engine_version                = "5.7.mysql_aurora.2.10.1"
  database_name                 = var.database_name
  master_username               = var.database_user
  master_password               = random_password.password.result
  backup_retention_period       = 5 // Think about
  deletion_protection           = true
  snapshot_identifier           = var.snapshot_id

  skip_final_snapshot = true
  storage_encrypted   = true
  # kms_key_id          = module.dev_db_kms_key.key_arn

  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name

  vpc_security_group_ids = [
    aws_security_group.proxy_db_sg.id
  ]

  lifecycle {
    ignore_changes = [
      engine_version,  // AWS may upgrade minor versions of the DB engine, adding this so we don't need to update our TF when that happens
    ]
  }
  tags = {
    Name = "${local.prefix}-aurora-cluster"
    Environment = var.environment
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name_prefix     = "${local.prefix}-subnet-group"
  description = "Subnet group for ${local.prefix}"
  subnet_ids = var.proxy_subnets
  tags = {
    Name = "${local.prefix}-subnet-group"
    Environment = var.environment
  }
}

resource "aws_rds_cluster_instance" "aurora_db_instance" {
  count              = var.instance_count
  identifier         = "${var.cluster_identifier}-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora_db.id
  instance_class     = "db.t3.medium"
  engine             = aws_rds_cluster.aurora_db.engine
  engine_version     = aws_rds_cluster.aurora_db.engine_version
  tags = {
    Name = "${local.prefix}-aurora-db-instance"
    Environment = var.environment
  }
}

resource "aws_db_proxy" "aurora_proxy" {
  name                = "${local.prefix}-proxy"
  engine_family       = "MYSQL"
  idle_client_timeout = 1800 // 30 min
  require_tls         = false
  role_arn            = aws_iam_role.proxy_iam_role.arn

  vpc_security_group_ids = [
    aws_security_group.lambda_proxy_sg.id,
    aws_security_group.proxy_db_sg.id
  ]
  vpc_subnet_ids = var.proxy_subnets

  auth {
    auth_scheme = "SECRETS"
    iam_auth    = "DISABLED"
    secret_arn  = aws_secretsmanager_secret.db_access_secret.arn
  }
  tags = {
    Name = "${local.prefix}-proxy"
    Environment = var.environment
  }
}

resource "aws_db_proxy_default_target_group" "aurora_proxy_target_group" {
  db_proxy_name = aws_db_proxy.aurora_proxy.name

  connection_pool_config {
    connection_borrow_timeout = 120
    max_connections_percent   = 95
  }
}

resource "aws_db_proxy_target" "aurora_proxy_target" {
  db_cluster_identifier = aws_rds_cluster.aurora_db.id
  db_proxy_name         = aws_db_proxy.aurora_proxy.name
  target_group_name     = aws_db_proxy_default_target_group.aurora_proxy_target_group.name
}

resource "aws_db_proxy_endpoint" "aurora_proxy_readonly_endpoint" {
  db_proxy_name          = aws_db_proxy.aurora_proxy.name
  db_proxy_endpoint_name = "${local.prefix}-proxy-readonly-endpoint"
  vpc_security_group_ids = [aws_security_group.lambda_proxy_sg.id]
  vpc_subnet_ids         = var.proxy_subnets
  target_role            = "READ_ONLY"
}

resource "aws_iam_role_policy" "proxy_iam_role_policy" {
  name = "${local.prefix}_proxy_role_policy"
  role = aws_iam_role.proxy_iam_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "GetSecretValue"
        Action = [
          "secretsmanager:GetSecretValue",
        ]
        Effect   = "Allow"
        Resource = aws_secretsmanager_secret.db_access_secret.arn
      },
      {
        Sid = "DecryptSecretValue"
        Action = [
          "kms:Decrypt",
        ]
        Effect   = "Allow"
        Resource = var.secrets_manager_key
        Condition = {
          StringEquals = {
            "kms:ViaService" = "secretsmanager.eu-west-2.amazonaws.com"
          }
        }
      }
    ]
  })
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


resource "aws_secretsmanager_secret" "db_access_secret" {
  name_prefix = "${local.prefix}_access_key"
  kms_key_id  = var.secrets_manager_key // right now this is just the aws managed one

}

resource "aws_secretsmanager_secret_version" "db_access_secret_value" {
  secret_id = aws_secretsmanager_secret.db_access_secret.id
  secret_string = jsonencode({
    dbInstanceIdentifier = var.cluster_identifier
    engine               = local.database_engine
    host                 = aws_rds_cluster.aurora_db.endpoint
    port                 = local.database_port
    resourceId           = aws_rds_cluster.aurora_db.cluster_resource_id
    username             = var.database_user
    password             = random_password.password.result
  })
}

resource "aws_security_group" "lambda_proxy_sg" {
  name        = "${var.env}_${var.cluster_identifier}_lamdba_proxy_sg"
  description = "Allow traffic between lambda and rds proxy"
  vpc_id      = var.vpc_id

  ingress = [
    {
      description = "Traffic between lambda and rds proxy"
      from_port   = local.database_port
      to_port     = local.database_port
      protocol    = "tcp"
      self        = true

      cidr_blocks      = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
    }
  ]

  egress = [
    {
      description = "Traffic between lambda and rds proxy"
      from_port   = local.database_port
      to_port     = local.database_port
      protocol    = "tcp"
      self        = true

      cidr_blocks      = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
    }
  ]

  tags = {
    Name = "${var.env}_${var.cluster_identifier}_lambda_proxy_sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "proxy_db_sg" {
  name        = "${var.env}_${var.cluster_identifier}_proxy_db_sg"
  description = "Allow traffic between rds proxy and aurora db"
  vpc_id      = var.vpc_id

  ingress = [
    {
      description = "Traffic between db and rds proxy"
      from_port   = local.database_port
      to_port     = local.database_port
      protocol    = "tcp"
      self        = true

      cidr_blocks      = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
    }
  ]

  egress = [
    {
      description = "Traffic between db and rds proxy"
      from_port   = local.database_port
      to_port     = local.database_port
      protocol    = "tcp"
      self        = true

      cidr_blocks      = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
    }
  ]

  tags = {
    Name = "${var.env}_${var.cluster_identifier}_proxy_db_sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ssm_parameter" "sg_id" {
  name        = "${var.env}_${var.cluster_identifier}_RDSProxySecurityGroupId"
  description = "Security group id for RDS Proxy"
  type        = "SecureString"
  value       = aws_security_group.lambda_proxy_sg.id

  tags = {
    environment = var.env
  }
}

resource "aws_ssm_parameter" "db_host" {
  name        = "${var.env}${var.ssm_db_host_name}"
  description = "Host for Aurora DB"
  type        = "SecureString"
  value       = aws_db_proxy.aurora_proxy.endpoint

  tags = {
    environment = var.env
  }
}

resource "aws_ssm_parameter" "db_ro_host" {
  name        = "${var.env}${var.ssm_db_ro_host_name}"
  description = "Read Only Host for Aurora DB"
  type        = "SecureString"
  value       = aws_db_proxy_endpoint.aurora_proxy_readonly_endpoint.endpoint

  tags = {
    environment = var.env
  }
}

resource "aws_ssm_parameter" "db_database_name" {
  name        = "${var.env}${var.ssm_db_database_name}"
  description = "Database name for Aurora DB"
  type        = "SecureString"
  value       = var.database_name

  tags = {
    environment = var.env
  }
}

resource "aws_ssm_parameter" "db_user" {
  name        = "${var.env}${var.ssm_db_user}"
  description = "User for Aurora DB"
  type        = "SecureString"
  value       = var.database_user

  tags = {
    environment = var.env
  }
}

resource "aws_ssm_parameter" "db_password" {
  name        = "${var.env}${var.ssm_db_password}"
  description = "Password for Aurora DB"
  type        = "SecureString"
  value       = random_password.password.result

  tags = {
    environment = var.env
  }
}