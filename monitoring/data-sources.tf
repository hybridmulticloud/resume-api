# API Gateway
data "aws_api_gateway_rest_api" "api" {
  name = var.rest_api_name
}

data "aws_api_gateway_stage" "api_stage" {
  rest_api_id = data.aws_api_gateway_rest_api.api.id
  stage_name  = var.api_stage_name
}

# Lambda (to pull environment/config if needed)
data "aws_lambda_function" "api_fn" {
  function_name = var.lambda_function_name
}

# CloudFront (SPA)
data "aws_cloudfront_distribution" "spa" {
  id = var.cloudfront_distribution_id
}

# S3 static site (for dashboard metrics)
data "aws_s3_bucket" "site" {
  bucket = var.site_bucket_name
}
