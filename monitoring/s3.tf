resource "aws_s3_bucket" "canary_artifacts" {
  bucket = local.bucket_name
  tags   = local.tags

  # supported in AWS provider v5.x+
  create_bucket_configuration {
    location_constraint = var.aws_region
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.canary_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.canary_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
