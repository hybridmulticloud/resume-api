terraform {
  required_version = ">= 1.2"
}

data "terraform_remote_state" "infra" {
  backend = "remote"
  config = {
    organization = "hybridmulticloud"
    workspaces = {
      name = "resume-api-backend"
    }
  }
}

locals {
  # Lambda outputs
  lambda_bucket_name        = data.terraform_remote_state.infra.outputs.lambda_bucket_name
  lambda_function_name      = data.terraform_remote_state.infra.outputs.lambda_function_name
  lambda_execution_role_arn = data.terraform_remote_state.infra.outputs.lambda_execution_role_arn
  lambda_exec_role_name     = data.terraform_remote_state.infra.outputs.lambda_exec_role_name

  # API Gateway
  api_endpoint    = data.terraform_remote_state.infra.outputs.api_endpoint
  api_gateway_url = data.terraform_remote_state.infra.outputs.api_gateway_url
  api_gateway_id  = split(".", replace(local.api_gateway_url, "https://", ""))[0]

  # DynamoDB & Frontend bucket
  dynamodb_table_name  = data.terraform_remote_state.infra.outputs.dynamodb_table_name
  frontend_bucket_name = data.terraform_remote_state.infra.outputs.frontend_bucket_name

  # CloudFront / Route53
  cloudfront_distribution_id = data.terraform_remote_state.infra.outputs.cloudfront_distribution_id
  cloudfront_oac_id          = data.terraform_remote_state.infra.outputs.cloudfront_oac_id
  route53_zone_id            = data.terraform_remote_state.infra.outputs.route53_zone_id
}
