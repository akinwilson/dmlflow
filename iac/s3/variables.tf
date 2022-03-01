variable "name" {
  description = "Name of service"
}

variable "region" {
  description = "bucket region"
}
variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "bucket_name" {
  description = "name to give to s3 bucket used as artifact store"
}