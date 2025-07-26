# Fetch the list of HTTP/WebSocket APIs by name,
# then pick the first ID into a local for easy reuse.
data "aws_apigatewayv2_apis" "monitored_api" {
  name          = var.api_gateway_name
  protocol_type = var.api_gateway_protocol_type
}

locals {
  api_id = tolist(data.aws_apigatewayv2_apis.monitored_api.ids)[0]
}
