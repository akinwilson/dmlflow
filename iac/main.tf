terraform {
    backend "s3" {
        bucket = "infra-euw2"
        key = "terraform-svc"
        region = "eu-west-2"
    }
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "3.73.0"
        }
    }
    required_version = ">=1.1.0"
}

provider "aws" {
    region = var.region 
}

module "vpc" {
    source = "./vpc"
    name = var.name
    cidr = var.cidr
    private_subnets = var.private_subnets
    public_subnets = var.public_subnets
    availability_zones = var.availability_zones
    environment        = var.environment
}
