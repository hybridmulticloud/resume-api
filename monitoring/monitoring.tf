#########################################################
# monitoring.tf
#  - Grabs function name & exec‐role name from remote state
#  - Attaches X-Ray policy
#  - Fires an AWS CLI proc to flip on Active tracing
#  - Sets up SNS e-mail, alarms and dashboard
#########################################################

locals {
  fn_name      = data.terraform_remote_state.backend.outputs.lambda_function_name
  exec_role    = data.terraform_remote_state.backend.outputs.lambda_exec_role_name
  table_name   = data.terraform_remote_state.backend.outputs.dynamodb_table_name
}

# 1) Attach inline X-Ray policy to the Lambda exec role
resource "aws_iam_role_policy" "lambda_xray" {
  name = "${var.project_name}-lambda-xray-policy"
  role = local.exec_role

  policy = jsonencode({
    Version   = "2012-10-17"
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

# 2) Turn on Active tracing by shelling out to AWS CLI
resource "null_resource" "enable_tracing" {
  depends_on = [aws_iam_role_policy.lambda_xray]

  provisioner "local-exec" {
    command = <<EOT
      aws lambda update-function-configuration \
        --function-name ${local.fn_name} \
        --tracing-config Mode=Active \
        --region ${var.aws_region}
    EOT
  }
}

# 3) SNS topic + subscription
resource "aws_sns_topic" "alarms" {
  name = "${var.project_name}-alarms-topic"
  tags = { Project = var.project_name }
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alert_email_address
}

# 4) CloudWatch alarms
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
  dimensions          = { TableName = local.table_name }
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_actions       = [aws_sns_topic.alarms.arn]
}

# 5) Dashboard
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
            ["AWS/Lambda","Invocations","FunctionName",local.fn_name],
            [".","Errors","FunctionName",local.fn_name,{"stat"="Sum"}]
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
            ["AWS/Lambda","Duration","FunctionName",local.fn_name,{"stat"="Average"}]
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
            ["AWS/DynamoDB","ThrottledRequests","TableName",local.table_name],
            [".","ConsumedReadCapacityUnits","TableName",local.table_name,{"stat"="Sum"}],
            [".","ConsumedWriteCapacityUnits","TableName",local.table_name,{"stat"="Sum"}]
          ]
        }
      }
    ]
  })
}
