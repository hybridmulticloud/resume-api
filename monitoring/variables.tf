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

variable "api_canary_name" {
  description = "Canary name for API (1–21 chars: lowercase, digits, hyphens, underscores)"
  type        = string
  default     = "resume-api-canary"
  validation {
    condition     = can(regex("^[a-z0-9_-]{1,21}$", var.api_canary_name))
    error_message = "api_canary_name must be 1–21 chars, lowercase alphanumeric, hyphens or underscores"
  }
}

variable "homepage_canary_name" {
  description = "Canary name for Homepage (1–21 chars: lowercase, digits, hyphens, underscores)"
  type        = string
  default     = "resume-home-canary"
  validation {
    condition     = can(regex("^[a-z0-9_-]{1,21}$", var.homepage_canary_name))
    error_message = "homepage_canary_name must be 1–21 chars, lowercase alphanumeric, hyphens or underscores"
  }
}

variable "tags" {
  description = "Map of tags to apply to all synthetics canaries"
  type        = map(string)
  default     = {}
}

variable "role_name" {
  description = "Name of the canary IAM role"
  type        = string
  default     = "resume-monitoring-canary-role"
}
