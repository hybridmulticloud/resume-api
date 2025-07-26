resource "aws_synthetics_canary" "homepage" {
  name                   = "${var.rest_api_id}-homepage-canary"
  artifact_s3_location   = "s3://${var.canary_artifact_bucket}/homepage/"
  execution_role_arn     = var.canary_execution_role_arn
  runtime_version        = "syn-nodejs-4.0"

  schedule {
    expression = "rate(5 minutes)"
  }

  run_config {
    timeout_in_seconds = 60
  }

  source_code {
    handler = "index.handler"
    script  = file("${path.module}/canary-homepage.js")
  }

  tags = {
    Name = "Homepage Canary"
  }
}
