variable "aws_region" {
  type        = string
  description = "AWS region to deploy into"
}

variable "rest_api_name" {            # e.g. "my-resume-api"
  type        = string
  description = "Name of the existing API Gateway REST API"
}

variable "api_stage_name" {
  type        = string
  description = "Stage name on that REST API (e.g. prod)"
}

variable "lambda_function_name" {
  type        = string
  description = "Name of the Lambda function behind the REST API"
}

variable "cloudfront_distribution_id" {
  type        = string
  description = "ID of the CloudFront distribution hosting the SPA"
}

variable "site_bucket_name" {
  type        = string
  description = "Name of the S3 bucket hosting the static site"
}

variable "alert_email" {
  type        = string
  description = "Email to receive alarms and canary failure notifications"
}

variable "canary_execution_role_arn" {
  type        = string
  description = "IAM Role ARN for Synthetic Canary execution"
}

variable "schedule_expression" {
  type        = string
  description = "Cron or rate expression for canary runs (e.g. rate(5 minutes))"
}

variable "homepage_canary_name" {
  type        = string
  description = "Name for the homepage synthetic canary"
}

variable "api_canary_name" {
  type        = string
  description = "Name for the API synthetic canary"
}
