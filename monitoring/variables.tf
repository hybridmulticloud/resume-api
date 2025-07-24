variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "rest_api_id" {
  description = "API Gateway REST API ID"
  type        = string
}

variable "api_stage_name" {
  description = "API Gateway stage name"
  type        = string
}

variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
}

variable "canary_artifact_bucket" {
  description = "S3 bucket for canary artifacts"
  type        = string
}

variable "canary_execution_role_arn" {
  description = "IAM role ARN for canaries"
  type        = string
}

variable "alert_email" {
  description = "Email address to subscribe to alarm notifications"
  type        = string
}
