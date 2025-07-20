variable "aws_region" {
  description = "AWS region for monitoring resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Base name for SNS topic & dashboard"
  type        = string
  default     = "resume-api"
}

variable "alert_email_address" {
  description = "Recipient e-mail for SNS alarm notifications"
  type        = string
}
