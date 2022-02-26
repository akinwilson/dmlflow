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
    region = var.region
    private_subnets = var.private_subnets
    public_subnets = var.public_subnets
    isolated_subnets = var.isolated_subnets
    availability_zones = var.availability_zones
    environment        = var.environment
}

module "sg" {
    source = "./sg"
    name = var.name
    environment = var.environment
}

module "rds" {
    source = "./rds"
    name = var.name
    environment = var.environment
    vpc_id = vpc.id
    sg = sg.rds 
}

module  "s3" {
    source = "./s3"
    name = var.name
    environment = var.environment   
}


module "alb" {
    source = "./alb"
    name = var.name
    environment = var.environment
    public_subnets = vpc.public
    vpc_id = vpc.id 
    sg = sg.alb 
}

module ecs {
    source = "./ecs"
    name = var.name
    environment = var.environment
}

module "ecr" {
    source = "./ecr"
    name = var.name
    environment = var.environment

}