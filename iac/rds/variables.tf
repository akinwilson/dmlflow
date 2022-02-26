variable "name" {
  description = "Name of service"
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "sg" {
  description = "security group for rds"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "snapshot_id" {
  type        = string
  description = "Snapshot of the latest RDS dev DB"
  default     = ""
}

variable "cluster_identifier" {
  type        = string
  description = "Name of the aurora cluster"
}

variable "database_name" {
  type        = string
  description = "Name of the DB in mysql"
  default     = ""
}

variable "database_user" {
  type        = string
  description = "Username for accessing the database"
  default     = ""
}

variable "database_password" {
  type        = string
  description = "Password for accessing the database"
  default     = ""
}

variable "replication_source_identifier" {
  type        = string
  description = "DB ID to create the read replica from"
  default     = ""
}

# variable "db_host_name" {
#   type        = string
#   description = "SSM parameter name for the db host"
# }

# variable "db_database_name" {
#   type        = string
#   description = "SSM parameter name for the db name"
#   default     = ""
# }

variable "instance_count" {
  type        = number
  description = "How many instances in the cluster"
  default     = 1
}

variable "isolated_subnets" {
  type        = list(string)
  description = "What subnets should the proxy for the db be in"
}