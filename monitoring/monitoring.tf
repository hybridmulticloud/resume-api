locals {
  fn_name   = data.terraform_remote_state.backend.outputs.lambda_function_name
  exec_role = data.terraform_remote_state.backend.outputs.lambda_exec_role_name
  tbl_name  = data.terraform_remote_state.backend.outputs.dynamodb_table_name
}

resource "aws_iam_role_policy" "lambda_xray" {
  name = "${var.project_name}-lambda-xray-policy"
  role = local.exec_role

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "xray:BatchGetTraces",
        "xray:GetServiceGraph",
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords",
      ]
      Resource = ["*"]
    }]
  })
}

data "aws_lambda_function" "original" {
  function_name = local.fn_name
}

resource "aws_lambda_function" "update_visitor_count_traced" {
  function_name    = "${local.fn_name}-traced"
  role             = local.exec_role
  handler          = data.aws_lambda_function.original.handler
  runtime          = data.aws_lambda_function.original.runtime
  filename         = data.aws_lambda_function.original.filename
  source_code_hash = data.aws_lambda_function.original.source_code_hash

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
  tags = { Project = var.project_name }
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alert_email_address
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.project_name}-lambda-errors"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  dimensions          = { FunctionName = local.fn_name }
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_actions       = [aws_sns_topic.alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "${var.project_name}-lambda-duration"
  namespace           = "AWS/Lambda"
  metric_name         = "Duration"
  dimensions          = { FunctionName = local.fn_name }
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1000
  comparison_operator = "GreaterThanThreshold"
  alarm_actions       = [aws_sns_topic.alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "dynamodb_throttles" {
  alarm_name          = "${var.project_name}-dynamodb-throttles"
  namespace           = "AWS/DynamoDB"
  metric_name         = "ThrottledRequests"
  dimensions          = { TableName = local.tbl_name }
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
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
            ["AWS/DynamoDB", "ThrottledRequests", "TableName", local.tbl_name],
            [".", "ConsumedReadCapacityUnits", "TableName", local.tbl_name, {"stat" = "Sum"}],
            [".", "ConsumedWriteCapacityUnits", "TableName", local.tbl_name, {"stat" = "Sum"}],
          ]
        }
      }
    ]
  })
}
