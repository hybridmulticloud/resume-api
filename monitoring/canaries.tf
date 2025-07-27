terraform {
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.1.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

provider "archive" {}

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
  handler              = "index.handler"
  artifact_s3_location = "s3://${aws_s3_bucket.canary_artifacts.bucket}/api"

  zip_file = data.archive_file.api_canary.output_base64

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
  handler              = "pageLoadBlueprint.handler"
  artifact_s3_location = "s3://${aws_s3_bucket.canary_artifacts.bucket}/homepage"

  zip_file = data.archive_file.homepage_canary.output_base64

  schedule {
    expression = var.schedule_expression
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = var.tags
}
