variable "project_name" {
  description = "Base name for all resources"
  type        = string
  default     = "resume-api"
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "lambda_function_name" {
  description = "Name of the existing Lambda function"
  type        = string
  default     = "UpdateVisitorCount"
}

variable "alert_email" {
  description = "Email address for CloudWatch alarm notifications"
  type        = string
  validation {
    condition     = length(var.alert_email) > 0
    error_message = "You must provide an alert_email"
  }
}

variable "schedule_expression" {
  description = "Rate expression for Synthetics canary"
  type        = string
  default     = "rate(10 minutes)"
}

variable "homepage_canary_name" {
  description = "Canary name for homepage"
  type        = string
  default     = "resume-homepage-canary"
  validation {
    condition     = can(regex("^[a-z0-9_-]+$", var.homepage_canary_name))
    error_message = "homepage_canary_name must be lowercase alphanumeric, hyphens or underscores only"
  }
}

variable "api_canary_name" {
  description = "Canary name for API"
  type        = string
  default     = "resume-api-canary"
  validation {
    condition     = can(regex("^[a-z0-9_-]+$", var.api_canary_name))
    error_message = "api_canary_name must be lowercase alphanumeric, hyphens or underscores only"
  }
}
