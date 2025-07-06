variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "lambda_function_name" {
  description = "Lambda function name"
  default     = "UpdateVisitorCount"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name"
  default     = "VisitorCount"
}

variable "lambda_runtime" {
  description = "Lambda function runtime"
  default     = "python3.11"
}
variable "lambda_s3_bucket" {
  description = "S3 bucket containing the Lambda function ZIP"
  type        = string
}

variable "lambda_s3_key" {
  description = "S3 key (path) to the Lambda function ZIP file"
  type        = string
}
