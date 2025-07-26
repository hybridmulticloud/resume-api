variable "project_name" {
  description = "Base name for all infra resources (matches infra default)"
  type        = string
  default     = "resume-api"
}

variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "frontend_domain" {
  description = "Custom domain for your SPA (CNAME on CloudFront & bucket name)"
  type        = string
  default     = "hybridmulti.cloud"
}

variable "lambda_function_name" {
  description = "Name of the existing Lambda function backing your API"
  type        = string
  default     = "UpdateVisitorCount"
}

variable "alert_email" {
  description = "Email address to receive CloudWatch alarm notifications"
  type        = string

  validation {
    condition     = length(var.alert_email) > 0
    error_message = "alert_email must be provided and non-empty"
  }
}

variable "schedule_expression" {
  description = "How often to run the Synthetics canaries"
  type        = string
  default     = "rate(10 minutes)"
}

variable "homepage_canary_name" {
  description = "Logical name for the homepage Canary"
  type        = string
  default     = "resume-homepage-canary"

  validation {
    condition     = can(regex("^[a-z0-9_-]+$", var.homepage_canary_name))
    error_message = "homepage_canary_name must be lowercase alphanumeric, hyphens or underscores only"
  }
}

variable "api_canary_name" {
  description = "Logical name for the API Canary"
  type        = string
  default     = "resume-api-canary"

  validation {
    condition     = can(regex("^[a-z0-9_-]+$", var.api_canary_name))
    error_message = "api_canary_name must be lowercase alphanumeric, hyphens or underscores only"
  }
}
