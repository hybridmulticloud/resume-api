data "aws_apigatewayv2_apis" "by_name" {
  names = [var.project_name]
}

locals {
  api_id = data.aws_apigatewayv2_apis.by_name.ids[0]
}

data "aws_lambda_function" "api_fn" {
  function_name = var.lambda_function_name
}
