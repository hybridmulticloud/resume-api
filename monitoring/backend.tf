terraform {
  backend "remote" {
    organization = "hybridmulticloud"
    workspaces {
      name = "resume-api-monitoring"
    }
  }
}
