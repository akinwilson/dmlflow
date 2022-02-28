resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name
  acl    = "private"
  force_destroy = true 
  # tags = {
  #   Name        = "${var.name}-artifacts-bucket-${var.environment}"
  #   Environment = var.environment
  # }
}

output "bucket" {
  value = aws_s3_bucket.main.id
}

