data "aws_api_gateway_rest_api" "api" {
  name = var.rest_api_name
}

data "aws_lambda_function" "api_fn" {
  function_name = var.lambda_function_name
}

data "aws_cloudfront_distribution" "spa" {
  id = var.cloudfront_distribution_id
}

data "aws_s3_bucket" "site" {
  bucket = var.site_bucket_name
}
