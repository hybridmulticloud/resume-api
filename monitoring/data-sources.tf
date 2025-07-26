data "terraform_remote_state" "backend" {
  backend = "s3"
  config = {
    bucket         = var.backend_state_bucket
    key            = var.backend_state_key
    region         = var.aws_region
    dynamodb_table = var.backend_lock_table
  }
}

locals {
  api_endpoint = data.terraform_remote_state.backend.outputs.api_endpoint
  api_id = regex("^https://([^\\.]+)\\.", local.api_endpoint)[0]
}
