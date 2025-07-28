resource "aws_s3_bucket" "canary_artifacts" {
  provider = aws.use1   # if you need us-east-1; otherwise omit
  bucket   = local.bucket_name
  tags     = local.tags

  # if your provider is already in the right region, you can omit this block
  create_bucket_configuration {
    location_constraint = var.aws_region
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  provider = aws.use1   # or default aws
  bucket   = aws_s3_bucket.canary_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  provider = aws.use1   # or default aws
  bucket   = aws_s3_bucket.canary_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
