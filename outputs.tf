output "api_gateway_url" {
  value = aws_apigatewayv2_stage.lambda_stage.invoke_url
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.visitors.name
}

output "lambda_s3_bucket" {
  value = aws_s3_bucket.lambda_bucket.bucket
}
output "api_endpoint" {
  description = "The HTTP endpoint for the Lambda function"
  value       = aws_apigatewayv2_api.lambda_api.api_endpoint
}
