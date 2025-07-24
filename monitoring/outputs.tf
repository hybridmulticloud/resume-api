output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}

output "homepage_canary_name" {
  value = aws_synthetics_canary.homepage.name
}

output "api_canary_name" {
  value = aws_synthetics_canary.api.name
}

output "dashboard_name" {
  value = aws_cloudwatch_dashboard.main.dashboard_name
}
