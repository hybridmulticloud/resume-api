variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string

  validation {
    condition     = length(var.aws_region) > 0
    error_message = "aws_region must be provided and non-empty"
  }
}

variable "rest_api_name" {
  description = "Name of the existing API Gateway REST API"
  type        = string

  validation {
    condition     = length(var.rest_api_name) > 0
    error_message = "rest_api_name must be provided and non-empty"
  }
}

variable "api_stage_name" {
  description = "Stage name for the REST API (e.g. prod, staging)"
  type        = string

  validation {
    condition     = length(var.api_stage_name) > 0
    error_message = "api_stage_name must be provided and non-empty"
  }
}

variable "lambda_function_name" {
  description = "Name of the existing Lambda function backing your API"
  type        = string

  validation {
    condition     = length(var.lambda_function_name) > 0
    error_message = "lambda_function_name must be provided and non-empty"
  }
}

variable "cloudfront_distribution_id" {
  description = "ID of the existing CloudFront distribution serving your SPA"
  type        = string

  validation {
    condition     = length(var.cloudfront_distribution_id) > 0
    error_message = "cloudfront_distribution_id must be provided and non-empty"
  }
}

variable "site_bucket_name" {
  description = "Name of the existing S3 bucket hosting your SPA"
  type        = string

  validation {
    condition     = length(var.site_bucket_name) > 0
    error_message = "site_bucket_name must be provided and non-empty"
  }
}

variable "alert_email" {
  description = "Email address to receive CloudWatch alarm notifications"
  type        = string

  validation {
    condition     = length(var.alert_email) > 0
    error_message = "alert_email must be provided and non-empty"
  }
}

variable "canary_execution_role_arn" {
  description = "IAM role ARN that Synthetics Canary will assume"
  type        = string

  validation {
    condition     = length(var.canary_execution_role_arn) > 0
    error_message = "canary_execution_role_arn must be provided and non-empty"
  }
}

variable "schedule_expression" {
  description = "CloudWatch Events schedule expression for canary runs"
  type        = string

  validation {
    condition     = length(var.schedule_expression) > 0
    error_message = "schedule_expression must be provided and non-empty"
  }
}

variable "homepage_canary_name" {
  description = "Logical name for the homepage Synthetics Canary (lowercase, numbers, hyphens or underscores only)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9_-]+$", var.homepage_canary_name))
    error_message = "homepage_canary_name must be lowercase alphanumeric, hyphens or underscores only"
  }
}

variable "api_canary_name" {
  description = "Logical name for the API Synthetics Canary (lowercase, numbers, hyphens or underscores only)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9_-]+$", var.api_canary_name))
    error_message = "api_canary_name must be lowercase alphanumeric, hyphens or underscores only"
  }
}
