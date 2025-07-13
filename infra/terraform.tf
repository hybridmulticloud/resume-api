terraform {
  backend "remote" {
    organization = "hybridmulticloud"

    workspaces {
      name = "resume-api-backend"
    }
  }
}
