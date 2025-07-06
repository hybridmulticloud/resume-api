variable "aws_region" {
  default = "us-east-1"
}

variable "lambda_function_name" {
  default = "UpdateVisitorCount"
}

variable "dynamodb_table_name" {
  default = "visitor_count"
}

variable "lambda_runtime" {
  default = "python3.12"
}

variable "lambda_s3_key" {
  description = "Name of the Lambda ZIP file in S3"
  default     = "lambda_function.zip"
}
