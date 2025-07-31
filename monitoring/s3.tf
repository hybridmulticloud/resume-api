resource "aws_s3_bucket" "canary_artifacts" {
  bucket = local.bucket_name
  tags   = local.tags
}

resource "null_resource" "bucket_ready" {
  depends_on = [aws_s3_bucket.canary_artifacts]

  provisioner "local-exec" {
    command = <<-EOT
      for i in {1..30}; do
        if aws s3api head-bucket --bucket "${local.bucket_name}" >/dev/null 2>&1; then
          exit 0
        fi
        sleep 2
      done
      echo "Bucket never became ready" >&2
      exit 1
    EOT
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  depends_on = [null_resource.bucket_ready]
  bucket     = aws_s3_bucket.canary_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  depends_on = [null_resource.bucket_ready]
  bucket     = aws_s3_bucket.canary_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
