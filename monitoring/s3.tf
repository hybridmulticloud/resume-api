# Generate a random suffix so buckets are globally unique
resource "random_id" "suffix" {
  byte_length = 4
}

# S3 bucket for Canary artifacts
resource "aws_s3_bucket" "canary_artifacts" {
  bucket        = "canary-artifacts-${random_id.suffix.hex}"
  force_destroy = true

  tags = {
    Name = "CanaryArtifacts"
  }
}

# Separate versioning resource to avoid deprecation warning
resource "aws_s3_bucket_versioning" "canary_artifacts_versioning" {
  bucket = aws_s3_bucket.canary_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Ensure server‐side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts_sse" {
  bucket = aws_s3_bucket.canary_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
