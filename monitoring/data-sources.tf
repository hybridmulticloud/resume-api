data "terraform_remote_state" "infra" {
  backend = "remote"
  config = {
    organization = "hybridmulticloud"
    workspaces   = { name = "resume-api-infra" }
  }
}

locals {
  api_gateway_id       = data.terraform_remote_state.infra.outputs.api_gateway_id
  lambda_function_name = data.terraform_remote_state.infra.outputs.lambda_function_name
}
