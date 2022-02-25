variable "name" {
  description = "Name of service"
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "cidr" {
  description = "The CIDR block for the VPC."
}

variable "public_subnets" {
  description = "List of public subnets"
}

variable "private_subnets" {
  description = "List of private subnets"
}

variable "isolated_subnets" {
  description = "List of isolated subnets"
}


variable "availability_zones" {
  description = "List of availability zones"
}
