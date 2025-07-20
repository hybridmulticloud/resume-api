variable "project_name" {
  description = "Base name for all resources"
  type        = string
  default     = "resume-api"
}

variable "alert_email_address" {
  description = "Email address to notify on alarm"
  type        = string
}
