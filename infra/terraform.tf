terraform {
  backend "remote" {
    organization = "your-hashicorp-org-name"

    workspaces {
      name = "resume-api-backend"
    }
  }
}
