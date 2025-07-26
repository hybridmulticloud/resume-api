data "aws_apigatewayv2_api" "monitored_api" {
  name = var.api_gateway_name
}
