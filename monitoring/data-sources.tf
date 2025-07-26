# 1) Look up the REST API by the same base name
data "aws_api_gateway_rest_api" "api" {
  name = var.project_name
}

# 2) Look up the Lambda function by name
data "aws_lambda_function" "api_fn" {
  function_name = var.lambda_function_name
}

# 3) Discover the CloudFront distribution via your CNAME
data "aws_cloudfront_distributions" "spa_list" {
  filter {
    name   = "CNAME"
    values = [var.frontend_domain]
  }
}

data "aws_cloudfront_distribution" "spa" {
  id = data.aws_cloudfront_distributions.spa_list.items[0].id
}

# 4) Lookup the S3 bucket that hosts your SPA
data "aws_s3_bucket" "site" {
  bucket = var.frontend_domain
}
