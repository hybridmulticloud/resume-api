variable "project_name" {
  type    = string
  default = "resume-api"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "schedule_expression" {
  type    = string
  default = "rate(5 minutes)"
}

variable "additional_tags" {
  type    = map(string)
  default = {}
}
