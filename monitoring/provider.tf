terraform {
  required_version = ">= 1.2"
}

provider "archive" {}

provider "aws" {
  region = var.aws_region
}
