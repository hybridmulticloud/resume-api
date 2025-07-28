data "external" "bucket_exists" {
  program = ["bash", "-c", <<-EOF
    if aws s3api head-bucket --bucket ${local.bucket_name} 2>/dev/null; then
      echo '{"exists":"true"}'
    else
      echo '{"exists":"false"}'
    fi
EOF
  ]
}

locals {
  create_bucket = data.external.bucket_exists.result.exists == "false"
}

resource "aws_s3_bucket" "canary_artifacts" {
  count  = local.create_bucket ? 1 : 0
  bucket = local.bucket_name
  acl    = "private"
  tags   = local.tags
}

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
