output "api_gateway_url" {
  description = "Invoke URL for API Gateway"
  value       = "${aws_apigatewayv2_api.lambda_api.api_endpoint}/UpdateVisitorCount"
}

output "dynamodb_table_name" {
  description = "DynamoDB table for counting visitors"
  value       = aws_dynamodb_table.visitor_count.name
}

output "lambda_function_name" {
  description = "Deployed Lambda function name"
  value       = aws_lambda_function.update_visitor_count.function_name
}

output "lambda_execution_role_arn" {
  description = "IAM role ARN assigned to the Lambda function"
  value       = aws_iam_role.lambda_exec.arn
}

output "api_endpoint" {
  description = "Base API Gateway endpoint URL"
  value       = aws_apigatewayv2_api.lambda_api.api_endpoint
}
