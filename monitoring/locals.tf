data "aws_caller_identity" "me" {}

locals {
  # Project prefix and derived names
  prefix               = var.project_name
  bucket_name          = "${local.prefix}-${data.aws_caller_identity.me.account_id}-canary-artifacts"
  api_canary_name      = "${local.prefix}-api-canary"
  homepage_canary_name = "${local.prefix}-homepage-canary"

  # ARNs for IAM policies
  bucket_arn     = "arn:aws:s3:::${local.bucket_name}"
  bucket_arn_all = "${local.bucket_arn}/*"

  # Tags merged with any extras
  tags = merge(
    {
      Project     = var.project_name
      Environment = "production"
    },
    var.additional_tags
  )
}
