// monitoring/canaries.tf

// S3 bucket for Canary artifacts
resource "aws_s3_bucket" "canary_artifacts" {
  bucket = "${var.project_name}-canary-artifacts-${substr(md5(var.project_name), 0, 8)}"
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

// API-targeting Canary
resource "aws_synthetics_canary" "api" {
  name                 = var.api_canary_name
  execution_role_arn   = local.canary_role_arn
  runtime_version      = "syn-nodejs-puppeteer-3.6"
  handler              = "index.handler"
  artifact_s3_location = "s3://${aws_s3_bucket.canary_artifacts.bucket}/api"
  zip_file             = data.archive_file.api_canary.output_base64

  schedule {
    expression = var.schedule_expression
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = var.tags
}

// Homepage-targeting Canary
resource "aws_synthetics_canary" "homepage" {
  name                 = var.homepage_canary_name
  execution_role_arn   = local.canary_role_arn
  runtime_version      = "syn-python-selenium-1.0"
  handler              = "pageLoadBlueprint.handler"
  artifact_s3_location = "s3://${aws_s3_bucket.canary_artifacts.bucket}/homepage"
  zip_file             = data.archive_file.homepage_canary.output_base64

  schedule {
    expression = var.schedule_expression
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = var.tags
}
