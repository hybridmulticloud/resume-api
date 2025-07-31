terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0, < 6.0.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.1.0"
    }
  }
  
  backend "remote" {
    organization = "hybridmulticloud"

    workspaces {
      name = "resume-api-backend-monitoring"
    }
  }
}
