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

resource "aws_iam_role" "canary_role" {
  name               = var.api_canary_name
  assume_role_policy = data.aws_iam_policy_document.canary_assume.json

  lifecycle {
    prevent_destroy       = true
    create_before_destroy = false
    ignore_changes        = [assume_role_policy]
  }
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.canary_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "synthetics" {
  role       = aws_iam_role.canary_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchSyntheticsFullAccess"
}

resource "aws_synthetics_canary" "api" {
  name                 = var.api_canary_name
  execution_role_arn   = aws_iam_role.canary_role.arn
  runtime_version      = "syn-nodejs-puppeteer-3.6"
  artifact_s3_location = "s3://${aws_s3_bucket.canary_artifacts.bucket}/${var.api_canary_name}"

  code {
    handler = "index.handler"
    script  = file("${path.module}/canaries/api/index.js")
  }

  schedule {
    expression = var.schedule_expression
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_synthetics_canary" "homepage" {
  name                 = var.homepage_canary_name
  execution_role_arn   = aws_iam_role.canary_role.arn
  runtime_version      = "syn-python-selenium-1.0"
  artifact_s3_location = "s3://${aws_s3_bucket.canary_artifacts.bucket}/${var.homepage_canary_name}"

  code {
    handler = "pageLoadBlueprint.handler"
    script  = file("${path.module}/canaries/homepage/index.js")
  }

  schedule {
    expression = var.schedule_expression
  }

  lifecycle {
    prevent_destroy = true
  }
}
