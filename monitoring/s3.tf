resource "aws_s3_bucket" "canary_artifacts" {
  bucket        = "canary-artifacts-${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "canary_artifacts_acl" {
  bucket = aws_s3_bucket.canary_artifacts.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "canary_artifacts_versioning" {
  bucket = aws_s3_bucket.canary_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts_sse" {
  bucket = aws_s3_bucket.canary_artifacts.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
