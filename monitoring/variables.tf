variable "project_name" {
  description = "Base name for all resources"
  type        = string
  default     = "resume-api"
}

variable "aws_region" {
  description = "The AWS region to operate in"
  type        = string
  default     = "us-east-1"   # adjust as needed
}

variable "api_canary_name" {
  description = "Name of the API synthetics canary"
  type        = string
  default     = "${var.project_name}-api-canary"
}

variable "homepage_canary_name" {
  description = "Name of the homepage synthetics canary"
  type        = string
  default     = "${var.project_name}-homepage-canary"
}

variable "schedule_expression" {
  description = "CloudWatch Schedule Expression (rate or cron) for canaries"
  type        = string
  default     = "rate(5 minutes)"
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = var.project_name
    Environment = "production"
  }
}
