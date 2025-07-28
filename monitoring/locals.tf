# Retrieve the AWS account ID for a globally-unique bucket name
data "aws_caller_identity" "me" {}

locals {
  # Base prefix for all resources
  prefix               = var.project_name

  # Globally-unique S3 bucket name
  bucket_name          = "${local.prefix}-${data.aws_caller_identity.me.account_id}-canary-artifacts"

  # Canary names derived from the same prefix
  api_canary_name      = "${local.prefix}-api-canary"
  homepage_canary_name = "${local.prefix}-homepage-canary"

  # Common tags, merge in any extras
  tags = merge(
    {
      Project     = var.project_name
      Environment = "production"
    },
    var.additional_tags
  )
}
