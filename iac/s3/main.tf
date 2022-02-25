resource "aws_s3_bucket" "main" {
  bucket = "mlflow-backend"
  tags {
        Name = "${var.name}-mlflow-backend-${var.environment}"
        Environment = var.environment
        }
}

resource "aws_s3_bucket_acl" "main" {
  bucket = aws_s3_bucket.main.id
  acl    = "private"
}