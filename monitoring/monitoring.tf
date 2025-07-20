#########################################################
# monitoring.tf
# — Enables X-Ray tracing, SNS e-mail alerts, CW alarms,
#   and a dashboard for your Lambda + DynamoDB stack.
#########################################################

# 1) IAM policy to let the Lambda role push X-Ray segments
resource "aws_iam_role_policy" "lambda_xray" {
  name = "${var.project_name}-lambda-xray-policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = [
        "xray:BatchGetTraces",
        "xray:GetServiceGraph",
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords"
      ]
      Resource = ["*"]
    }]
  })
}

# 2) Re-create the Lambda with active tracing (pulls everything else from existing function)
resource "aws_lambda_function" "update_visitor_count_traced" {
  function_name    = aws_lambda_function.update_visitor_count.function_name
  role             = aws_lambda_function.update_visitor_count.role
  handler          = aws_lambda_function.update_visitor_count.handler
  runtime          = aws_lambda_function.update_visitor_count.runtime
  filename         = aws_lambda_function.update_visitor_count.filename
  source_code_hash = aws_lambda_function.update_visitor_count.source_code_hash

  environment {
    variables = aws_lambda_function.update_visitor_count.environment[0].variables
  }

  tracing_config { mode = "Active" }

  lifecycle {
    ignore_changes = [ filename, source_code_hash ]
  }

  depends_on = [ aws_iam_role_policy.lambda_xray ]
}

# 3) SNS topic + email subscription
resource "aws_sns_topic" "alarms" {
  name = "${var.project_name}-alarms-topic"
  tags = { Project = var.project_name }
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alert_email_address
}

# 4) CloudWatch alarms wired to that topic
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.project_name}-lambda-errors"
  alarm_description   = "Lambda errors ≥1 in 5m"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  dimensions          = { FunctionName = aws_lambda_function.update_visitor_count.function_name }
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [ aws_sns_topic.alarms.arn ]
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "${var.project_name}-lambda-duration"
  alarm_description   = "Lambda avg duration >1000ms in 5m"
  namespace           = "AWS/Lambda"
  metric_name         = "Duration"
  dimensions          = { FunctionName = aws_lambda_function.update_visitor_count.function_name }
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1000
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [ aws_sns_topic.alarms.arn ]
}

resource "aws_cloudwatch_metric_alarm" "dynamodb_throttles" {
  alarm_name          = "${var.project_name}-dynamodb-throttles"
  alarm_description   = "DynamoDB throttled reqs ≥1 in 5m"
  namespace           = "AWS/DynamoDB"
  metric_name         = "ThrottledRequests"
  dimensions          = { TableName = aws_dynamodb_table.visitor_count.name }
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [ aws_sns_topic.alarms.arn ]
}

# 5) Dashboard
resource "aws_cloudwatch_dashboard" "ops" {
  dashboard_name = "${var.project_name}-ops-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type       = "metric"; x = 0; y = 0; width = 12; height = 6
        properties = {
          title   = "Lambda Invocations & Errors"
          view    = "timeSeries"
          region  = var.aws_region
          metrics = [
            ["AWS/Lambda","Invocations","FunctionName",aws_lambda_function.update_visitor_count.function_name],
            [".","Errors","FunctionName",aws_lambda_function.update_visitor_count.function_name,{"stat":"Sum"}]
          ]
        }
      },
      {
        type       = "metric"; x = 0; y = 6; width = 12; height = 6
        properties = {
          title   = "Lambda Duration (ms)"
          view    = "timeSeries"
          region  = var.aws_region
          metrics = [
            ["AWS/Lambda","Duration","FunctionName",aws_lambda_function.update_visitor_count.function_name,{"stat":"Average"}]
          ]
        }
      },
      {
        type       = "metric"; x = 12; y = 0; width = 12; height = 6
        properties = {
          title   = "DynamoDB Throttles & Capacity"
          view    = "timeSeries"
          region  = var.aws_region
          metrics = [
            ["AWS/DynamoDB","ThrottledRequests","TableName",aws_dynamodb_table.visitor_count.name],
            [".","ConsumedReadCapacityUnits","TableName",aws_dynamodb_table.visitor_count.name,{"stat":"Sum"}],
            [".","ConsumedWriteCapacityUnits","TableName",aws_dynamodb_table.visitor_count.name,{"stat":"Sum"}]
          ]
        }
      }
    ]
  })
}
