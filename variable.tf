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
  description = "Name for the S3 bucket to store Lambda ZIP"
  type        = string
  default     = "my-lambda-zip-bucket-${random_id.suffix.hex}"
}

variable "lambda_s3_key" {
  description = "Path (key) in S3 bucket for Lambda ZIP"
  type        = string
  default     = "lambda_function.zip"
}

resource "random_id" "suffix" {
  byte_length = 4
}
