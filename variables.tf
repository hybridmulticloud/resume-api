variable "aws_region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "resume-api"
}

variable "lambda_function_name" {
  default = "UpdateVisitorCount"
}

variable "dynamodb_table_name" {
  default = "VisitorCount"
}

variable "lambda_runtime" {
  default = "python3.12"
}