variable "project_name" {
  description = "Base name for all resources (matches infra)"
  type        = string
  default     = "resume-api"
}

variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "alert_email" {
  description = "Email address to receive CloudWatch alarm notifications"
  type        = string
}

variable "schedule_expression" {
  description = "Frequency for the Synthetics canaries"
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
