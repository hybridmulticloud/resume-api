terraform {
  backend "remote" {
    organization = "your-hashicorp-org-name"

    workspaces {
      name = "cloud-resume-backend"
    }
  }
}
