variable "project_name" {
  description = "Base name for all resources"
  type        = string
  default     = "resume-api"
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
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

variable "homepage_canary_name" {
  description = "Logical name for the homepage Canary"
  type        = string
  default     = "resume-homepage-canary"
}

variable "api_canary_name" {
  description = "Logical name for the API Canary"
  type        = string
  default     = "resume-api-canary"
}
