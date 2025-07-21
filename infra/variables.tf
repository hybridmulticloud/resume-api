variable "project_name" {
  description = "Base name for all resources"
  type        = string
  default     = "resume-api"
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "ssl_min_protocol_version" {
  description = "Minimum TLS protocol version for CloudFront distribution"
  type        = string
  default     = "TLSv1.2_2021"
}

variable "lambda_s3_key" {
  description = "S3 key for Lambda ZIP file"
  type        = string
  default     = "function.zip"
}

variable "lambda_zip_hash" {
  description = "Base64 SHA256 hash of the Lambda ZIP for source_code_hash"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "UpdateVisitorCount"
}

variable "lambda_runtime" {
  description = "Lambda runtime version"
  type        = string
  default     = "python3.12"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "VisitorCount"
}

variable "frontend_bucket_name" {
  description = "S3 bucket name used for static website hosting"
  type        = string
  default     = "hybridmulti.cloud"
}

variable "frontend_domain" {
  description = "Custom domain for the static site"
  type        = string
  default     = "hybridmulti.cloud"
}

variable "index_document" {
  description = "Default root object for CloudFront"
  type        = string
  default     = "index.html"
}

variable "cloudfront_origin_id" {
  description = "CloudFront origin ID label"
  type        = string
  default     = "s3-frontend-static-site"
}

variable "cert_region" {
  description = "Region for ACM certificate (must be us-east-1 for CloudFront)"
  type        = string
  default     = "us-east-1"
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID for the frontend domain"
  type        = string
}
