# Execution role for both canaries
resource "aws_iam_role" "canary_role" {
  name = "${var.project_name}-synthetics-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "synthetics.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.canary_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "synthetics" {
  role       = aws_iam_role.canary_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchSyntheticsFullAccess"
}

# Bucket for canary artifacts
resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.project_name}-canary-artifacts"
  acl           = "private"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Homepage canary (you drop homepage.zip into canaries/homepage/)
data "archive_file" "homepage" {
  type        = "zip"
  source_dir  = "${path.module}/canaries/homepage"
  output_path = "${path.module}/homepage.zip"
}

resource "aws_synthetics_canary" "homepage" {
  name                 = var.homepage_canary_name
  execution_role_arn   = aws_iam_role.canary_role.arn
  runtime_version      = "syn-python-selenium-1.0"
  handler              = "pageLoadBlueprint.handler"
  schedule {
    expression = var.schedule_expression
  }

  artifact_s3_location = "s3://${aws_s3_bucket.artifacts.bucket}/${var.homepage_canary_name}"

  zip_file = filebase64(data.archive_file.homepage.output_path)
}

# API canary (you drop api.zip into canaries/api/)
data "archive_file" "api" {
  type        = "zip"
  source_dir  = "${path.module}/canaries/api"
  output_path = "${path.module}/api.zip"
}

resource "aws_synthetics_canary" "api" {
  name                 = var.api_canary_name
  execution_role_arn   = aws_iam_role.canary_role.arn
  runtime_version      = "syn-nodejs-puppeteer-3.6"
  handler              = "index.handler"
  schedule {
    expression = var.schedule_expression
  }

  artifact_s3_location = "s3://${aws_s3_bucket.artifacts.bucket}/${var.api_canary_name}"

  zip_file = filebase64(data.archive_file.api.output_path)
}
