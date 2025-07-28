resource "aws_s3_bucket" "canary_artifacts" {
  bucket = "${var.project_name}-canary-artifacts"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "canary_artifacts_sse" {
  bucket = aws_s3_bucket.canary_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
