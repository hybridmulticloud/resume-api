resource "aws_sns_topic" "alerts" {
  name = "${var.rest_api_id}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "api_5xx" {
  alarm_name        = "${var.rest_api_id}-api-5xx"
  namespace         = "AWS/ApiGateway"
  metric_name       = "5XXError"
  dimensions = {
    ApiId = var.rest_api_id
    Stage = var.api_stage_name
  }
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name        = "${var.lambda_function_name}-errors"
  namespace         = "AWS/Lambda"
  metric_name       = "Errors"
  dimensions = {
    FunctionName = var.lambda_function_name
  }
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_synthetics_canary" "homepage" {
  name                   = "${var.rest_api_id}-homepage-canary"
  artifact_s3_location   = "s3://${var.canary_artifact_bucket}/homepage/"
  execution_role_arn     = var.canary_execution_role_arn
  runtime_version        = "syn-nodejs-4.0"
  handler                = "index.handler"

  schedule {
    expression = "rate(5 minutes)"
  }

  run_config {
    timeout_in_seconds = 60
  }

  script = <<-EOF
    const synthetics = require('Synthetics');
    const page = await synthetics.getPage();
    const res = await page.goto("https://$${aws_cloudfront_distribution.main.domain_name}", { waitUntil: 'networkidle0' });
    if (res.status() !== 200) throw new Error(\`Status $${res.status()}\`);
  EOF

  tags = {
    Name = "Homepage Canary"
  }
}

resource "aws_synthetics_canary" "api" {
  name                   = "${var.rest_api_id}-api-canary"
  artifact_s3_location   = "s3://${var.canary_artifact_bucket}/api/"
  execution_role_arn     = var.canary_execution_role_arn
  runtime_version        = "syn-nodejs-4.0"
  handler                = "index.handler"

  schedule {
    expression = "rate(5 minutes)"
  }

  run_config {
    timeout_in_seconds = 60
  }

  script = <<-EOF
    const synthetics = require('Synthetics');
    const log = require('SyntheticsLogger');
    const url = "https://$${aws_api_gateway_rest_api.main.execution_arn}/$${var.api_stage_name}/UpdateVisitorCount";
    const res = await synthetics.executeHttpStep('post-count', {
      url,
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({})
    });
    if (res.statusCode !== 200) throw new Error(\`Status $${res.statusCode}\`);
  EOF

  tags = {
    Name = "API Canary"
  }
}

resource "aws_cloudwatch_metric_alarm" "homepage_canary_fail" {
  alarm_name        = "${var.rest_api_id}-homepage-canary-fail"
  namespace         = "CloudWatchSynthetics"
  metric_name       = "Failed"
  dimensions = {
    CanaryName = aws_synthetics_canary.homepage.name
  }
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "api_canary_fail" {
  alarm_name        = "${var.rest_api_id}-api-canary-fail"
  namespace         = "CloudWatchSynthetics"
  metric_name       = "Failed"
  dimensions = {
    CanaryName = aws_synthetics_canary.api.name
  }
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.rest_api_id}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type       = "metric",
        x          = 0,
        y          = 0,
        width      = 12,
        height     = 6,
        properties = {
          metrics = [
            [ "AWS/ApiGateway", "5XXError", "ApiId", var.rest_api_id, "Stage", var.api_stage_name ]
          ],
          region = var.aws_region,
          stat   = "Sum"
        }
      },
      {
        type       = "metric",
        x          = 12,
        y          = 0,
        width      = 12,
        height     = 6,
        properties = {
          metrics = [
            [ "AWS/Lambda", "Errors", "FunctionName", var.lambda_function_name ]
          ],
          region = var.aws_region,
          stat   = "Sum"
        }
      }
    ]
  })
}
