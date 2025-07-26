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
  api_endpoint = data.terraform_remote_state.backend.outputs.api_endpoint
  api_id       = regex("^https://([^\\.]+)\\.", local.api_endpoint)[0]
}
