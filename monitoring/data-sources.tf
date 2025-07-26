# Lookup HTTP API by project_name
data "aws_apigatewayv2_api" "api" {
  name = var.project_name
}

# Lookup Lambda function by name
data "aws_lambda_function" "api_fn" {
  function_name = var.lambda_function_name
}
