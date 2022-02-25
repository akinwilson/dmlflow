variable "env" {
  type        = string
  description = "Envionment this infra will be running in e.g. dev or prod"
  default     = "prod"
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

variable "ssm_db_host_name" {
  type        = string
  description = "SSM parameter name for the db host"
}

variable "ssm_db_ro_host_name" {
  type        = string
  description = "SSM parameter name for the readonly db host"
}

variable "ssm_db_database_name" {
  type        = string
  description = "SSM parameter name for the db name"
  default     = ""
}

variable "ssm_db_user" {
  type        = string
  description = "SSM parameter name for the db user"
  default     = ""
}

variable "ssm_db_password" {
  type        = string
  description = "SSM parameter name for the db password"
  default     = ""
}

variable "instance_count" {
  type        = number
  description = "How many instances in the cluster"
  default     = 1
}

variable "proxy_subnets" {
  type        = list(string)
  description = "What subnets should the proxy for the db be in"
}

variable "secrets_manager_key" {
  type        = string
  description = "KMS key arn for decrypting secrets manager secrets"
}