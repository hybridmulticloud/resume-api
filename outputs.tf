output "api_gateway_url" {
  value = aws_apigatewayv2_stage.lambda_stage.invoke_url
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.visitors.name
}

output "lambda_s3_bucket" {
  value = aws_s3_bucket.lambda_bucket.id
}