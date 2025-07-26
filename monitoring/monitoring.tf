resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"

  timeouts {
    create = "1m"
    delete = "1m"
  }
}

resource "aws_cloudwatch_metric_alarm" "api_5xx" {
  alarm_name          = "${var.project_name}-api-5xx"
  namespace           = "AWS/ApiGateway"
  metric_name         = "5XXError"
  dimensions          = { ApiId = local.api_id }
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"
  dashboard_body = jsonencode({ widgets = [
    { type = "metric", x = 0, y = 0, width = 12, height = 6,
      properties = {
        metrics = [[ "AWS/ApiGateway", "5XXError", "ApiId", local.api_id ]]
        stat    = "Sum"
        period  = 300
        region  = var.aws_region
        title   = "API Gateway 5XX Errors"
      }
    },
    { type = "metric", x = 12, y = 0, width = 12, height = 6,
      properties = {
        metrics = [[ "AWS/Lambda", "Errors", "FunctionName", var.lambda_function_name ]]
        stat    = "Sum"
        period  = 300
        region  = var.aws_region
        title   = "Lambda Function Errors"
      }
    }
  ]})
}
