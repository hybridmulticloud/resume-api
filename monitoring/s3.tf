# Main artifacts bucket
resource "aws_s3_bucket" "canary_artifacts" {
  bucket = local.bucket_name
  tags   = local.tags

  # Ensure bucket is created in the correct region (requires aws provider >= 5.0)
  create_bucket_configuration {
    location_constraint = var.aws_region
  }
}

# Enable versioning on the bucket
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.canary_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enforce AES256 server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.canary_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
