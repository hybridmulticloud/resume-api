# 1) Probe existence via AWS CLI
data "external" "bucket_exists" {
  program = [
    "bash", "-c", <<-EOF
      if aws s3api head-bucket --bucket ${local.bucket_name} 2>/dev/null; then
        echo '{"exists":"true"}'
      else
        echo '{"exists":"false"}'
      fi
    EOF
  ]
}

# 2) Conditionally create only if missing
resource "aws_s3_bucket" "canary_artifacts" {
  count  = local.create_bucket ? 1 : 0
  bucket = local.bucket_name
  tags   = local.tags
}

# 3) Always enforce versioning & encryption on that name
resource "aws_s3_bucket_versioning" "canary_artifacts_versioning" {
  bucket = local.bucket_name

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "canary_artifacts_sse" {
  bucket = local.bucket_name

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
