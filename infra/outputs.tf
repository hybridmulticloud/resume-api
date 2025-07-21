output "lambda_bucket_name" {
  description = "Bucket where Lambda ZIP is stored"
  value       = aws_s3_bucket.lambda_bucket.id
}

output "api_gateway_url" {
  description = "Full API Gateway invoke URL"
  value       = "${aws_apigatewayv2_api.lambda_api.api_endpoint}/UpdateVisitorCount"
}

output "api_endpoint" {
  description = "Base API Gateway endpoint URL"
  value       = aws_apigatewayv2_api.lambda_api.api_endpoint
}

output "cloudfront_distribution_id" {
  description = "CloudFront Distribution ID for frontend"
  value       = aws_cloudfront_distribution.frontend.id
}

output "cloudfront_oac_id" {
  description = "CloudFront Origin Access Control ID for frontend"
  value       = aws_cloudfront_origin_access_control.frontend_oac.id
}

output "frontend_bucket_name" {
  description = "S3 bucket name for frontend"
  value       = var.frontend_bucket_name
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.visitor_count.name
}

output "lambda_execution_role_arn" {
  description = "IAM role ARN assigned to the Lambda function"
  value       = aws_iam_role.lambda_exec.arn
}

output "lambda_exec_role_name" {
  description = "Name of the Lambda execution role"
  value       = aws_iam_role.lambda_exec.name
}

output "route53_zone_id" {
  description = "Route53 Hosted Zone ID"
  value       = var.route53_zone_id
}
