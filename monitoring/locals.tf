locals {
  # Constructed names, derived from project_name
  api_canary_name      = "${var.project_name}-api-canary"
  homepage_canary_name = "${var.project_name}-homepage-canary"
  bucket_name          = "${var.project_name}-canary-artifacts"

  # Default tags, merged with any extra ones
  tags = merge({
    Project     = var.project_name
    Environment = "production"
  }, var.additional_tags)
}
