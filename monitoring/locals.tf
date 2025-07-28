locals {
  # Base names
  api_canary_name      = "${var.project_name}-api-canary"
  homepage_canary_name = "${var.project_name}-homepage-canary"
  bucket_name          = "${var.project_name}-canary-artifacts"

  # Tags
  tags = merge(
    {
      Project     = var.project_name
      Environment = "production"
    },
    var.additional_tags
  )
}
