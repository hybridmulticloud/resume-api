locals {
  homepage_dir = "${path.module}/canaries/homepage"
  api_dir      = "${path.module}/canaries/api"
}

data "archive_file" "homepage_zip" {
  type        = "zip"
  source_dir  = local.homepage_dir
  output_path = "${path.module}/homepage.zip"
}

data "archive_file" "api_zip" {
  type        = "zip"
  source_dir  = local.api_dir
  output_path = "${path.module}/api.zip"
}

resource "aws_synthetics_canary" "homepage" {
  name                 = var.homepage_canary_name
  artifact_s3_location = "s3://${aws_s3_bucket.canary_artifacts.bucket}/homepage/"
  execution_role_arn   = var.canary_execution_role_arn
  runtime_version      = "syn-nodejs-puppeteer-3.6"
  handler              = "index.handler"
  start_canary         = true

  schedule {
    expression          = var.schedule_expression
    duration_in_seconds = 120
  }

  run_config {
    timeout_in_seconds = 60
  }

  zip_file = filebase64(data.archive_file.homepage_zip.output_path)

  tags = {
    Component = "HomepageCanary"
  }
}

resource "aws_synthetics_canary" "api" {
  name                 = var.api_canary_name
  artifact_s3_location = "s3://${aws_s3_bucket.canary_artifacts.bucket}/api/"
  execution_role_arn   = var.canary_execution_role_arn
  runtime_version      = "syn-nodejs-puppeteer-3.6"
  handler              = "index.handler"
  start_canary         = false

  schedule {
    expression          = var.schedule_expression
    duration_in_seconds = 120
  }

  run_config {
    timeout_in_seconds = 60
  }

  zip_file = filebase64(data.archive_file.api_zip.output_path)

  tags = {
    Component = "ApiCanary"
  }
}
