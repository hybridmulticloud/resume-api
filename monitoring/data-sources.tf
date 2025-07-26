# Pull in your backend stack’s outputs (api_endpoint, etc.)
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
  # The full invoke URL, e.g. https://abc123.execute-api.us-east-1.amazonaws.com/Prod
  api_endpoint = data.terraform_remote_state.backend.outputs.api_endpoint

  # Extract the API ID (“abc123” above) via regex
  api_id = regex("^https://([^\\.]+)\\.", local.api_endpoint)
}
