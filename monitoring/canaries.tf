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

resource "aws_synthetics_canary" "api" {
  name                        = var.api_canary_name
  execution_role_arn          = aws_iam_role.canary_role.arn
  runtime_version             = "syn-nodejs-puppeteer-3.6"
  handler                     = "index.handler"
  artifact_s3_location        = "s3://${aws_s3_bucket.canary_artifacts.bucket}/api"
  start_canary_after_creation = true

  schedule {
    expression = var.schedule_expression
  }

  code {
    handler = "index.handler"
    script  = file("${path.module}/canaries/api/index.js")
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = var.tags
}

resource "aws_synthetics_canary" "homepage" {
  name                        = var.homepage_canary_name
  execution_role_arn          = aws_iam_role.canary_role.arn
  runtime_version             = "syn-python-selenium-1.0"
  handler                     = "pageLoadBlueprint.handler"
  artifact_s3_location        = "s3://${aws_s3_bucket.canary_artifacts.bucket}/homepage"
  start_canary_after_creation = true

  schedule {
    expression = var.schedule_expression
  }

  code {
    handler = "pageLoadBlueprint.handler"
    script  = file("${path.module}/canaries/homepage/index.js")
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = var.tags
}
