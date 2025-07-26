variable "project_name" {
  description = "Base name for all resources (matches infra default)"
  type        = string
  default     = "resume-api"
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "lambda_function_name" {
  description = "Name of the existing Lambda function (infra default)"
  type        = string
  default     = "UpdateVisitorCount"
}

variable "alert_email" {
  description = "Email address to receive CloudWatch alarm notifications"
  type        = string

  validation {
    condition     = length(var.alert_email) > 0
    error_message = "alert_email must be provided"
  }
}

variable "schedule_expression" {
  description = "How often to run the Synthetics canaries"
  type        = string
  default     = "rate(10 minutes)"
}

variable "api_gateway_name" {
  description = "Name of the API Gateway to reference"
  type        = string
}

variable "environment" {
  description = "Deployment environment name (e.g. dev, prod)"
  type        = string
}

variable "homepage_canary_name" {
  description = "Name for the homepage Canary (lowercase/hyphens/underscores)"
  type        = string
  default     = "resume-homepage-canary"

  validation {
    condition     = can(regex("^[a-z0-9_-]+$", var.homepage_canary_name))
    error_message = "homepage_canary_name must be lowercase alphanumeric, hyphens or underscores only"
  }
}

variable "api_canary_name" {
  description = "Name for the API Canary (lowercase/hyphens/underscores)"
  type        = string
  default     = "resume-api-canary"

  validation {
    condition     = can(regex("^[a-z0-9_-]+$", var.api_canary_name))
    error_message = "api_canary_name must be lowercase alphanumeric, hyphens or underscores only"
  }
}
