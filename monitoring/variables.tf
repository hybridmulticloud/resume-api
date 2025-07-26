variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "rest_api_name" {
  description = "Existing API Gateway name"
  type        = string
}

variable "api_stage_name" {
  description = "Stage of that REST API (e.g. prod)"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda behind that API"
  type        = string
}

variable "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  type        = string
}

variable "site_bucket_name" {
  description = "Name of the S3 bucket hosting your SPA"
  type        = string
}

variable "alert_email" {
  description = "Email for SNS alarm notifications"
  type        = string
}

variable "canary_execution_role_arn" {
  description = "IAM Role ARN for Synthetic Canary execution"
  type        = string
}

variable "schedule_expression" {
  description = "Cron or rate expression for canary runs"
  type        = string
}

variable "homepage_canary_name" {
  description = "Logical name for the homepage canary"
  type        = string
}

variable "api_canary_name" {
  description = "Logical name for the API canary"
  type        = string
}
