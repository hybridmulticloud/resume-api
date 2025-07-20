# Lambda error count alarm
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "lambda_errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Trigger when Lambda errors exceed 0 in a minute"
  dimensions = {
    FunctionName = data.aws_lambda_function.update_visitor_count.function_name
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

# Lambda duration alarm
resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "lambda_duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Average"
  threshold           = 3000     # 3 seconds
  alarm_description   = "Trigger when Lambda duration exceeds 3s"
  dimensions = {
    FunctionName = data.aws_lambda_function.update_visitor_count.function_name
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

# DynamoDB throttle alarm
resource "aws_cloudwatch_metric_alarm" "dynamodb_throttles" {
  alarm_name          = "dynamodb_throttles"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ThrottledRequests"
  namespace           = "AWS/DynamoDB"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Trigger when DynamoDB table is throttled"
  dimensions = {
    TableName = data.aws_dynamodb_table.visitor_count.name
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

# Operations dashboard
resource "aws_cloudwatch_dashboard" "ops" {
  dashboard_name = "ops-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        x    = 0
        y    = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            [ "AWS/Lambda", "Invocations", "FunctionName", data.aws_lambda_function.update_visitor_count.function_name ],
            [ ".",          "Errors",      "FunctionName", data.aws_lambda_function.update_visitor_count.function_name, { stat = "Sum" } ]
          ]
          period = 60
          title  = "Lambda Invocations vs Errors"
        }
      },
      {
        type = "metric"
        x    = 12
        y    = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            [ "AWS/Lambda", "Duration", "FunctionName", data.aws_lambda_function.update_visitor_count.function_name, { stat = "Average" } ]
          ]
          period = 60
          title  = "Lambda Duration"
        }
      },
      {
        type = "metric"
        x    = 0
        y    = 6
        width  = 24
        height = 6
        properties = {
          metrics = [
            [ "AWS/DynamoDB", "ThrottledRequests",           "TableName", data.aws_dynamodb_table.visitor_count.name ],
            [ ".",            "ConsumedReadCapacityUnits",  "TableName", data.aws_dynamodb_table.visitor_count.name, { stat = "Sum" } ],
            [ ".",            "ConsumedWriteCapacityUnits", "TableName", data.aws_dynamodb_table.visitor_count.name, { stat = "Sum" } ]
          ]
          period = 60
          title  = "DynamoDB Utilization"
        }
      }
    ]
  })
}
