data "archive_file" "api_canary" {
  type        = "zip"
  source_dir  = "${path.module}/canaries/api"
  output_path = "${path.module}/.terraform/cache/api_canary.zip"
}

data "archive_file" "homepage_canary" {
  type        = "zip"
  source_dir  = "${path.module}/canaries/homepage"
  output_path = "${path.module}/.terraform/cache/homepage_canary.zip"
}

resource "aws_synthetics_canary" "api" {
  name                 = var.api_canary_name
  execution_role_arn   = local.canary_role_arn
  runtime_version      = "syn-nodejs-puppeteer-3.6"
  artifact_s3_location = "s3://${aws_s3_bucket.canary_artifacts.bucket}/api"

  code {
    handler  = "index.handler"
    zip_file = filebase64(data.archive_file.api_canary.output_path)
  }

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
  execution_role_arn   = local.canary_role_arn
  runtime_version      = "syn-python-selenium-1.0"
  artifact_s3_location = "s3://${aws_s3_bucket.canary_artifacts.bucket}/homepage"

  code {
    handler  = "pageLoadBlueprint.handler"
    zip_file = filebase64(data.archive_file.homepage_canary.output_path)
  }

  schedule {
    expression = var.schedule_expression
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = var.tags
}
