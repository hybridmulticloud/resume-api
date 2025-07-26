# Canary artifacts S3 bucket
resource "aws_s3_bucket" "canary_artifacts" {
  bucket        = "canary-artifacts-${var.environment}"
  force_destroy = true

  tags = {
    Environment = var.environment
    Name        = "canary-artifacts"
  }
}

resource "aws_s3_bucket_versioning" "canary_artifacts_versioning" {
  bucket = aws_s3_bucket.canary_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}
