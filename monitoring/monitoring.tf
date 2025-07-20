locals {
  fn_name    = data.terraform_remote_state.backend.outputs.lambda_function_name
  role_arn   = data.terraform_remote_state.backend.outputs.lambda_execution_role_arn
  handler    = data.terraform_remote_state.backend.outputs.lambda_handler
  runtime    = data.terraform_remote_state.backend.outputs.lambda_runtime
  filename   = data.terraform_remote_state.backend.outputs.lambda_artifact_filename
  hash       = data.terraform_remote_state.backend.outputs.lambda_artifact_hash
  table_name = data.terraform_remote_state.backend.outputs.dynamodb_table_name
}

resource "aws_iam_role_policy" "lambda_xray" {
  name = "${var.project_name}-lambda-xray-policy"
  role = local.role_arn

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = [
        "xray:BatchGetTraces",
        "xray:GetServiceGraph",
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords",
      ]
      Resource = ["*"]
    }]
  })
}

resource "aws_lambda_function" "update_visitor_count_traced" {
  function_name    = local.fn_name
  role             = local.role_arn
  handler          = local.handler
  runtime          = local.runtime
  filename         = local.filename
  source_code_hash = local.hash

  tracing_config {
    mode = "Active"
  }

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }

  depends_on = [aws_iam_role_policy.lambda_xray]
}

resource "aws_sns_topic" "alarms" {
  name = "${var.project_name}-alarms-topic"
  tags = {
    Project = var.project_name
  }
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alert_email_address
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.project_name}-lambda-errors"
  alarm_description   = "Lambda errors ≥ 1 in 5m"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  dimensions          = { FunctionName = local.fn_name }
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "${var.project_name}-lambda-duration"
  alarm_description   = "Lambda avg duration > 1000ms in 5m"
  namespace           = "AWS/Lambda"
  metric_name         = "Duration"
  dimensions          = { FunctionName = local.fn_name }
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1000
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "dynamodb_throttles" {
  alarm_name          = "${var.project_name}-dynamodb-throttles"
  alarm_description   = "DynamoDB throttled requests ≥ 1 in 5m"
  namespace           = "AWS/DynamoDB"
  metric_name         = "ThrottledRequests"
  dimensions          = { TableName = local.table_name }
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alarms.arn]
}

resource "aws_cloudwatch_dashboard" "ops" {
  dashboard_name = "${var.project_name}-ops-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type       = "metric"
        x          = 0
        y          = 0
        width      = 12
        height     = 6
        properties = {
          title   = "Lambda Invocations & Errors"
          view    = "timeSeries"
          region  = var.aws_region
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", local.fn_name],
            [".", "Errors", "FunctionName", local.fn_name, {"stat" = "Sum"}],
          ]
        }
      },
      {
        type       = "metric"
        x          = 0
        y          = 6
        width      = 12
        height     = 6
        properties = {
          title   = "Lambda Duration (ms)"
          view    = "timeSeries"
          region  = var.aws_region
          metrics = [
            ["AWS/Lambda", "Duration", "FunctionName", local.fn_name, {"stat" = "Average"}],
          ]
        }
      },
      {
        type       = "metric"
        x          = 12
        y          = 0
        width      = 12
        height     = 6
        properties = {
          title   = "DynamoDB Throttles & Capacity"
          view    = "timeSeries"
          region  = var.aws_region
          metrics = [
            ["AWS/DynamoDB", "ThrottledRequests", "TableName", local.table_name],
            [".", "ConsumedReadCapacityUnits", "TableName", local.table_name, {"stat" = "Sum"}],
            [".", "ConsumedWriteCapacityUnits", "TableName", local.table_name, {"stat" = "Sum"}],
          ]
        }
      }
    ]
  })
}
