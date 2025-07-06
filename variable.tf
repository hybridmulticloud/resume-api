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
  default     = "python3.13"
}
