data "terraform_remote_state" "backend" {
  backend = "remote"

  config = {
    organization = "hybridmulticloud"
    workspaces   = { name = "resume-api-backend" }
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
