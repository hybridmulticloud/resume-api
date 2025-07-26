variable "project_name" {
  type    = string
  default = "resume-api"
}

variable "lambda_function_name" {
  type    = string
  default = "UpdateVisitorCount"
}

// 1. List all HTTP APIs, filter by name = your project_name
data "aws_apigatewayv2_apis" "by_name" {
  names = [var.project_name]
}

// 2. Pull the first (and only) match into a local
locals {
  api_id = data.aws_apigatewayv2_apis.by_name.ids[0]
}

// 3. Lookup your Lambda by its existing name
data "aws_lambda_function" "api_fn" {
  function_name = var.lambda_function_name
}
