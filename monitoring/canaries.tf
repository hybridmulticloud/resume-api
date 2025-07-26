resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_iam_role" "canary_role" {
  name               = "${var.project_name}-synthetics-role"
  assume_role_policy = data.aws_iam_policy_document.canary_assume.json

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [assume_role_policy]
  }
}

resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.project_name}-canary-artifacts"
  force_destroy = true

  lifecycle {
    prevent_destroy = true
  }
}
