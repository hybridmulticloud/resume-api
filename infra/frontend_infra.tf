# S3 Bucket for Static Website Hosting (private)
resource "aws_s3_bucket" "frontend" {
  bucket = var.frontend_bucket_name

  tags = {
    Project = var.project_name
  }
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = var.index_document
  }

  error_document {
    key = var.error_document
  }
}

# BLOCK PUBLIC ACCESS (secure)
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ACM certificate lookup (must exist in us-east-1)
provider "aws" {
  alias  = "us_east_1"
  region = var.cert_region
}

data "aws_acm_certificate" "frontend_cert" {
  provider    = aws.us_east_1
  domain      = var.frontend_domain
  statuses    = ["ISSUED"]
  most_recent = true
}

# CloudFront OAC
resource "aws_cloudfront_origin_access_control" "frontend_oac" {
  name                              = "frontend-oac"
  description                       = "OAC for frontend static site"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution using OAC
resource "aws_cloudfront_distribution" "frontend" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CDN for ${var.frontend_domain}"
  default_root_object = var.index_document

  aliases = [var.frontend_domain]

  origin {
    domain_name = "${aws_s3_bucket.frontend.bucket}.s3.${var.aws_region}.amazonaws.com"
    origin_id   = var.cloudfront_origin_id

    origin_access_control_id = aws_cloudfront_origin_access_control.frontend_oac.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.cloudfront_origin_id

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.frontend_cert.arn
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Project = var.project_name
  }
}
