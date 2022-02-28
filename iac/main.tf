terraform {
  backend "s3" {
    bucket = "infra-euw2"
    key    = "terraform-svc"
    region = "eu-west-2"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.73.0"
    }
  }
  required_version = ">=1.1.0"
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source             = "./vpc"
  name               = var.name
  cidr               = var.cidr
  region             = var.region
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  isolated_subnets   = var.isolated_subnets
  availability_zones = var.availability_zones
  environment        = var.environment
}

module "sg" {
  source      = "./sg"
  name        = var.name
  environment = var.environment
  vpc_id      = module.vpc.id
}

module "rds" {
  source           = "./rds"
  name             = var.name
  environment      = var.environment
  vpc_id           = module.vpc.id
  sg               = [module.sg.rds]
  isolated_subnets = module.vpc.isolated
}

module "s3" {
  source      = "./s3"
  name        = var.name
  environment = var.environment
  region      = var.region
  bucket_name = var.bucket_name
}


module "alb" {
  source         = "./alb"
  name           = var.name
  environment    = var.environment
  public_subnets = module.vpc.public
  vpc_id         = module.vpc.id
  sg             = [module.sg.alb]
}

module "ecs" {
  source                = "./ecs"
  name                  = var.name
  region                = var.region
  sg                    = [module.sg.ecs]
  ecr_repo_url          = module.ecr.ecr_repo_url
  alb_target_group_arn  = module.alb.alb_target_group_arn
  service_desired_count = var.service_desired_count
  environment           = var.environment
  private_subnets       = module.vpc.private
  container_port        = var.container_port
  container_cpu         = var.container_cpu
  container_memory      = var.container_memory
  dependency_on_ecr     = module.ecr.dependency_on_ecr
  artifact_bucket       = module.s3.bucket
  db_host               = module.rds.db_host
  db_name               = module.rds.db_name
  db_user               = module.rds.db_username
  db_password           = module.rds.db_password
}

module "ecr" {
  source      = "./ecr"
  name        = var.name
  environment = var.environment

}
# Note that we want to linked the name of the state bucket to the 
# to where within the resource below it is mentioned 

# recall that ./utils/create-bucket uses the same name as below 
data "aws_iam_policy_document" "iam_policy_document" {
  statement {
    sid     = "AllowSpecificS3FullAccess"
    actions = ["s3:*"]
    effect  = "Allow"
    resources = [
      "arn:aws:s3:::*/*",
      "arn:aws:s3:::*",
      "arn:aws:s3:::infra-euw2",
      "arn:aws:s3:::infra-euw2",
    ]
  }

  statement {
    sid = "AllowSecurityGroups"
    actions = [
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSecurityGroupsRules",
      "ec2:DescribeTags",
      "ec2:CreateTags",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:ModifySecurityGroupEgress",
      "ec2:ModifySecurityGroupRuleDescriptionIngress",
      "ec2:ModifySecurityGroupRuleDescriptionEgress",
      "ec2:ModifySecurityGroupRules",
      "ec2:CreateSecurityGroup"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    sid = "AllowEC2"
    actions = [
      "ec2:*"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    sid = "AllowIAM"
    actions = [
      "iam:*"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    sid = "AllowSecretsManager"
    actions = [
      "secretsmanager:*"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    sid = "AllowSSM"
    actions = [
      "ssm:PutParameter",
      "ssm:DeleteParameter",
      "ssm:GetParameterHistory",
      "ssm:GetParametersByPath",
      "ssm:GetParameters",
      "ssm:GetParameter",
      "ssm:DeleteParameters",
      "ssm:DescribeParameters",
      "ssm:AddTagsToResource",
      "ssm:ListTagsForResource"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "iam_policy" {
  name   = "terraform-iam-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.iam_policy_document.json
}

resource "aws_iam_user" "terraform_agent_user" {
  name = "terraform_agent_user"
}

resource "aws_iam_user_policy_attachment" "tf_attach" {
  user       = aws_iam_user.terraform_agent_user.name
  policy_arn = aws_iam_policy.iam_policy.arn
}