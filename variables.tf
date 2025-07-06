variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
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
