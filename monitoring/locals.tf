data "aws_caller_identity" "me" {}

locals {
  prefix      = var.project_name
  bucket_name = "${local.prefix}-${data.aws_caller_identity.me.account_id}-canary-artifacts"

  api_canary_name      = "${local.prefix}-api-canary"
  homepage_canary_name = "${local.prefix}-homepage-canary"

  tags = merge(
    { Project = var.project_name, Environment = "production" },
    var.additional_tags
  )
}
