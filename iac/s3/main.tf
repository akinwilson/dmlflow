resource "aws_s3_bucket" "main" {
  bucket = "mlflow-artifacts"
  acl    = "private"
  tags = {
    Name        = "${var.name}-mlflow-artifacts-bucket-${var.environment}"
    Environment = var.environment
  }
}

output "bucket" {
  value = aws_s3_bucket.main.id
}

