resource "aws_iam_role" "canary_exec_role" {
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

resource "aws_iam_role_policy_attachment" "canary_logs" {
  role       = aws_iam_role.canary_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "canary_synthetics" {
  role       = aws_iam_role.canary_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchSyntheticsFullAccess"
}

# ---- Homepage Canary ----
resource "aws_synthetics_canary" "homepage" {
  name               = var.homepage_canary_name
  execution_role_arn = aws_iam_role.canary_exec_role.arn
  runtime_version    = "syn-python-selenium-1.0"
  schedule {
    expression = var.schedule_expression
  }
  artifact_s3_location = "s3://${data.aws_s3_bucket.site.bucket}/canary-artifacts/${var.homepage_canary_name}"
  handler               = "pageLoadBlueprint.handler"

  code {
    handler = "pageLoadBlueprint.handler"
    bucket  = data.aws_s3_bucket.site.bucket
    key     = "canary-scripts/homepage.zip"
  }
}

# ---- API Canary ----
resource "aws_synthetics_canary" "api" {
  name               = var.api_canary_name
  execution_role_arn = aws_iam_role.canary_exec_role.arn
  runtime_version    = "syn-nodejs-puppeteer-3.2"
  schedule {
    expression = var.schedule_expression
  }
  artifact_s3_location = "s3://${data.aws_s3_bucket.site.bucket}/canary-artifacts/${var.api_canary_name}"
  handler               = "apiTest.handler"

  code {
    handler = "apiTest.handler"
    bucket  = data.aws_s3_bucket.site.bucket
    key     = "canary-scripts/api.zip"
  }

  depends_on = [aws_iam_role_policy_attachment.canary_synthetics]
}
