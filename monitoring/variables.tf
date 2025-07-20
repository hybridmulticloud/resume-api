variable "project_name" {
  description = "Base name for all resources"
  type        = string
  default     = "resume-api"
}

variable "aws_region" {
  description = "AWS region to deploy monitoring resources in"
  type        = string
}

variable "alert_email_address" {
  description = "Email address to notify on alarm"
  type        = string
}
