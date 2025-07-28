data "aws_caller_identity" "me" {}

locals {
  prefix               = var.project_name

  # Globally-unique bucket name
  bucket_name          = "${local.prefix}-${data.aws_caller_identity.me.account_id}-canary-artifacts"

  # ARNs for IAM policies
  bucket_arn           = "arn:aws:s3:::${local.bucket_name}"
  bucket_arn_all       = "${local.bucket_arn}/*"

  # Canary names
  api_canary_name      = "${local.prefix}-api-canary"
  homepage_canary_name = "${local.prefix}-homepage-canary"

  # Tags
  tags = merge(
    {
      Project     = var.project_name
      Environment = "production"
    },
    var.additional_tags
  )
}
