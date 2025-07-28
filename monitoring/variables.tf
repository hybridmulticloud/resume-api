variable "project_name" {
  description = "Base name for all resources"
  type        = string
  default     = "resume-api"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "schedule_expression" {
  description = "CloudWatch schedule (rate or cron)"
  type        = string
  default     = "rate(5 minutes)"
}

variable "additional_tags" {
  description = "Extra tags to merge with the default ones"
  type        = map(string)
  default     = {}
}
