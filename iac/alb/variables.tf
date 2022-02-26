variable "name" {
  description = "name of of stack module"
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "public_subnets" {
  description = "Comma separated list of subnet IDs"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "sg" {
  description = "Comma separated list of security groups"
}
