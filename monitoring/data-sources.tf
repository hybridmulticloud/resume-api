# Read backend’s outputs directly from Terraform Cloud
data "terraform_remote_state" "backend" {
  backend = "remote"
  config = {
    organization = "hybridmulticloud"
    workspaces = {
      name = "resume-api-backend"
    }
  }
}

locals {
  # Full invoke URL from backend output, e.g.
  # "https://abc123.execute-api.us-east-1.amazonaws.com/Prod"
  api_endpoint = data.terraform_remote_state.backend.outputs.api_endpoint

  # Extract just the "<api-id>" (e.g. "abc123") as a STRING
  api_id = regex("^https://([^\\.]+)\\.", local.api_endpoint)[0]
}
