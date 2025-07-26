variable "rest_api_id" {
  description = "The REST API Gateway ID"
  type        = string
}

variable "api_stage_name" {
  description = "API Gateway stage name"
  type        = string
}

variable "lambda_function_name" {
  description = "Lambda function name linked to the API"
  type        = string
}

variable "alert_email" {
  description = "Email to receive alert notifications"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
}

variable "canary_artifact_bucket" {
  description = "S3 bucket to store canary test artifacts"
  type        = string
}

variable "canary_execution_role_arn" {
  description = "IAM role ARN for running synthetic canaries"
  type        = string
}

variable "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  type        = string
}
