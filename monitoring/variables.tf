variable "project_name" {
  description = "Base prefix for all resources"
  type        = string
  default     = "resume-api"
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "schedule_expression" {
  description = "CloudWatch schedule for canaries"
  type        = string
  default     = "rate(5 minutes)"
}

variable "additional_tags" {
  description = "Extra tags to merge in"
  type        = map(string)
  default     = {}
}
