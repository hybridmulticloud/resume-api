variable "project_name" {
  description = "Base name for all resources"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to operate in"
  type        = string
}

variable "api_canary_name" {
  description = "Name of the API synthetics canary"
  type        = string
}

variable "homepage_canary_name" {
  description = "Name of the homepage synthetics canary"
  type        = string
}

variable "schedule_expression" {
  description = "CloudWatch Schedule Expression (rate or cron) for canaries"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}
