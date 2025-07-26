resource "aws_synthetics_canary" "api" {
  name                      = "${var.rest_api_id}-api-canary"
  artifact_s3_location      = "s3://${var.canary_artifact_bucket}/api/"
  execution_role_arn        = var.canary_execution_role_arn
  runtime_version           = "syn-nodejs-4.0"
  start_time                = null

  schedule {
    expression = "rate(5 minutes)"
  }

  run_config {
    timeout_in_seconds = 60
  }

  source_code {
    s3_bucket_arn = null
    handler       = "index.handler"
    script        = file("${path.module}/canary-api.js")
  }

  tags = {
    Name = "API Canary"
  }
}
