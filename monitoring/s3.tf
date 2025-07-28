resource "aws_s3_bucket" "canary_artifacts" {
  # use the us-east-1 provider so we don't need a location block
  provider = aws.use1

  bucket = local.bucket_name
  tags   = local.tags
}

resource "aws_s3_bucket_versioning" "versioning" {
  # must manage versioning in the same region as the bucket
  provider = aws.use1

  bucket = aws_s3_bucket.canary_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  # likewise for SSE
  provider = aws.use1

  bucket = aws_s3_bucket.canary_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
