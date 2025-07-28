data "archive_file" "api_canary" {
  type        = "zip"
  source_dir  = "${path.module}/canaries/api"
  output_path = "${path.module}/canaries/api.zip"
}

data "archive_file" "homepage_canary" {
  type        = "zip"
  source_dir  = "${path.module}/canaries/homepage"
  output_path = "${path.module}/canaries/homepage.zip"
}

resource "aws_s3_bucket_object" "api_zip" {
  bucket = aws_s3_bucket.canary_artifacts.bucket
  key    = "${var.api_canary_name}.zip"
  source = data.archive_file.api_canary.output_path
}

resource "aws_s3_bucket_object" "homepage_zip" {
  bucket = aws_s3_bucket.canary_artifacts.bucket
  key    = "${var.homepage_canary_name}.zip"
  source = data.archive_file.homepage_canary.output_path
}

resource "aws_synthetics_canary" "api" {
  name                 = var.api_canary_name
  execution_role_arn   = aws_iam_role.canary.arn
  runtime_version      = "syn-nodejs-puppeteer-3.6"
  handler              = "index.handler"
  s3_bucket            = aws_s3_bucket.canary_artifacts.bucket
  s3_key               = aws_s3_bucket_object.api_zip.key
  artifact_s3_location = "s3://${aws_s3_bucket.canary_artifacts.bucket}/api"

  schedule {
    expression = var.schedule_expression
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = var.tags
}

resource "aws_synthetics_canary" "homepage" {
  name                 = var.homepage_canary_name
  execution_role_arn   = aws_iam_role.canary.arn
  runtime_version      = "syn-python-selenium-1.0"
  handler              = "pageLoadBlueprint.handler"
  s3_bucket            = aws_s3_bucket.canary_artifacts.bucket
  s3_key               = aws_s3_bucket_object.homepage_zip.key
  artifact_s3_location = "s3://${aws_s3_bucket.canary_artifacts.bucket}/homepage"

  schedule {
    expression = var.schedule_expression
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = var.tags
}
