# Fetch your AWS account ID for a globally-unique bucket name
data "aws_caller_identity" "me" {}

locals {
  # Base prefix
  prefix               = var.project_name

  # Globally-unique S3 bucket name
  bucket_name          = "${local.prefix}-${data.aws_caller_identity.me.account_id}-canary-artifacts"

  # Bucket ARNs for IAM policies
  bucket_arn           = "arn:aws:s3:::${local.bucket_name}"
  bucket_arn_all       = "${local.bucket_arn}/*"

  # Synthetic canary names
  api_canary_name      = "${local.prefix}-api-canary"
  homepage_canary_name = "${local.prefix}-homepage-canary"

  # Common tags
  tags = merge(
    {
      Project     = var.project_name
      Environment = "production"
    },
    var.additional_tags
  )
}
