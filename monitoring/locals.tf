data "aws_caller_identity" "current" {}

locals {
  prefix           = var.project_name
  bucket_name      = "${local.prefix}-canary-artifacts"
  bucket_arn       = "arn:aws:s3:::${local.bucket_name}"
  bucket_arn_all   = "${local.bucket_arn}/*"
  tags             = merge(
                       { Project = var.project_name, Environment = "production" },
                       var.additional_tags,
                     )
  create_bucket    = lookup(
                       data.external.bucket_exists.result, 
                       "exists", 
                       "false"
                     ) == "false"
}
