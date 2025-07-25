// assume‐role policy
data "aws_iam_policy_document" "canary_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["synthetics.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

// zip API folder
data "archive_file" "api_canary" {
  type        = "zip"
  source_dir  = "${path.module}/canaries/api"
  output_path = "${path.module}/canaries/api.zip"
}

// API canary
resource "aws_synthetics_canary" "api" {
  name                 = var.api_canary_name
  execution_role_arn   = aws_iam_role.canary_role.arn
  runtime_version      = "syn-nodejs-puppeteer-3.6"
  handler              = "index.handler"
  artifact_s3_location = "s3://${aws_s3_bucket.canary_artifacts.bucket}/api"
  zip_file = filebase64(data.archive_file.api_canary.output_path)

  schedule {
    expression = var.schedule_expression
  }

  lifecycle {
    prevent_destroy = true
  }
}

// zip homepage folder
data "archive_file" "homepage_canary" {
  type        = "zip"
  source_dir  = "${path.module}/canaries/homepage"
  output_path = "${path.module}/canaries/homepage.zip"
}

// Homepage canary
resource "aws_synthetics_canary" "homepage" {
  name                 = var.homepage_canary_name
  execution_role_arn   = aws_iam_role.canary_role.arn
  runtime_version      = "syn-python-selenium-1.0"
  handler              = "pageLoadBlueprint.handler"
  artifact_s3_location = "s3://${aws_s3_bucket.canary_artifacts.bucket}/homepage"
  zip_file             = filebase64(data.archive_file.homepage_canary.output_path)

  schedule {
    expression = var.schedule_expression
  }

  lifecycle {
    prevent_destroy = true
  }
}
