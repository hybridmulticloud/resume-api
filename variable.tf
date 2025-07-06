variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
  default     = "UpdateVisitorCount"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name"
  type        = string
  default     = "VisitorCount"
}

variable "lambda_runtime" {
  description = "Runtime environment for the Lambda function"
  type        = string
  default     = "python3.12"
}

variable "lambda_s3_key" {
  description = "The key (filename) for the Lambda zip in S3"
  type        = string
  default     = "lambda_function.zip"
}
