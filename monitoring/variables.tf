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

variable "lambda_exec_role_name" {
  description = "Name of the IAM Role used by the Lambda function"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function to monitor"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table to monitor"
  type        = string
}
