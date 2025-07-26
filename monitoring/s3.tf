resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "canary_artifacts" {
  bucket        = "canary-artifacts-${random_id.suffix.hex}"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  tags = {
    Name = "CanaryArtifacts"
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
