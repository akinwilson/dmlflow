terraform {
    backend "s3" {
        bucket = "infra-euw2"
        key = "terraform-svc"
        region = "eu-west-2"
    }
}