resource "aws_s3_bucket" "main" {
  bucket = "mlflow-artifacts-bucket"
  tags {
        Name = "${var.name}-mlflow-artifacts-bucket-${var.environment}"
        Environment = var.environment
        }
}

resource "aws_s3_bucket_acl" "main" {
  bucket = aws_s3_bucket.main.id
  acl    = "private"
}