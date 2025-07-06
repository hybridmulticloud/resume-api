output "api_gateway_url" {
  value = aws_apigatewayv2_stage.lambda_stage.invoke_url
}

output "dynamodb_table_name" {
  description = "DynamoDB table for counting visitors"
  value       = aws_dynamodb_table.visitor_count.name
}

output "lambda_s3_bucket" {
  description = "Name of the S3 bucket for Lambda"
  value       = aws_s3_bucket.lambda_bucket.bucket
}

output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = aws_apigatewayv2_api.lambda_api.api_endpoint
}
