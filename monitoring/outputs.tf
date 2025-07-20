output "alarm_arns" {
  description = "List of created CloudWatch alarm ARNs"
  value       = [
    aws_cloudwatch_metric_alarm.lambda_errors.arn,
    aws_cloudwatch_metric_alarm.lambda_duration.arn,
    aws_cloudwatch_metric_alarm.dynamodb_throttles.arn,
  ]
}
