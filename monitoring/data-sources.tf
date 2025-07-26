terraform {
  required_version = ">= 1.2"
}

# Point at the infra state file (no S3 or remote bucket required)
data "terraform_remote_state" "infra" {
  backend = "local"

  config = {
    path = "../infra/terraform.tfstate"
  }
}

# Convenience locals for each infra output.  
# Update each key to the exact name you declared in infra/outputs.tf.
locals {
  api_url             = data.terraform_remote_state.infra.outputs.api_gateway_url
  api_gateway_id   = split(".", replace(local.api_endpoint, "https://", ""))[0]
  lambda_function_arn = data.terraform_remote_state.infra.outputs.lambda_function_arn
  lambda_function_name  = var.lambda_function_name
  
  dynamodb_table_name = data.terraform_remote_state.infra.outputs.dynamodb_table_name
  website_bucket_name = data.terraform_remote_state.infra.outputs.website_bucket_name
}
