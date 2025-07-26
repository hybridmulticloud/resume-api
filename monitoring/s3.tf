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

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "CanaryArtifacts"
  }
}
