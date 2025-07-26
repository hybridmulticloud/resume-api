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

# Now outputs pull from the local.api_id instead of a (non-existent) data source
output "api_gateway_id" {
  description = "The ID of the API Gateway identified by name"
  value       = local.api_id
}

output "monitored_api_id" {
  description = "The ID of the monitored API Gateway"
  value       = local.api_id
}
