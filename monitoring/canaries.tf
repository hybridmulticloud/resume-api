# Generate a random suffix so buckets are globally unique
resource "random_id" "suffix" {
  byte_length = 4
}

# Build the assume-role policy for Synthetics Canaries
data "aws_iam_policy_document" "canary_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["synthetics.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# IAM role for your Synthetics Canary
resource "aws_iam_role" "canary_role" {
  name               = "${var.project_name}-synthetics-role"
  assume_role_policy = data.aws_iam_policy_document.canary_assume.json

  lifecycle {
    prevent_destroy = true
    create_before_destroy = false
    ignore_changes  = [assume_role_policy]
  }
}

# Attach the AWSLambdaBasicExecutionRole managed policy
resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.canary_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach the Synthetics full-access policy
resource "aws_iam_role_policy_attachment" "synthetics" {
  role       = aws_iam_role.canary_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchSyntheticsFullAccess"
}

# S3 bucket for raw Canary artifacts
resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.project_name}-canary-artifacts"
  force_destroy = true

  lifecycle {
    prevent_destroy = true
  }
}
