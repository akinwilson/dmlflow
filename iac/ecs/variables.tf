variable "name" {
  description = "Name of stack module"

}
variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "region" {
  description = "the AWS region in which resources are created"
}

variable "private_subnets" {
  description = "List of subnet IDs"
}

variable "sg" {
  description = "Comma separated list of security groups"
}

variable "container_port" {
  description = "Port of container"
}

variable "container_cpu" {
  description = "The number of cpu units used by the task"
}

variable "container_memory" {
  description = "The amount (in MiB) of memory used by the task"
}

variable "alb_target_group_arn" {
  description = "ARN of the alb target group"
}

variable "service_desired_count" {
  description = "Number of services running in parallel"
}

variable "artifact_bucket" {
  description = "Bucket used for backend store arn"
}

variable "db_user" {
  description = "aurora database admin user"

}

variable "db_password" {
  description = "aurora database admin password"

}

variable "db_host" {
  description = "aurora database host name"
}

variable "db_name" {
  description = "aurora database name"
}

variable "db_port" {
  description = "aurora databse service port"
  default = 3036
}

# variable "container_environment" {
#   description = "The container environmnent variables"
#   type        = list(any)
# }


variable "ecr_repo_url" {
  description = "URL of the repostory container the image to be served over ECS"
}

variable "dependency_on_ecr" {
  description = "Ensure that ecs task is not started until the image required is in the repo"


}

