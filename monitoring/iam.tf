data "aws_iam_policy_document" "assume_synthetics" {
  statement {
    actions    = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["synthetics.amazonaws.com"]
    }
  }
}

data "aws_iam_role" "existing_canary_role" {
  name = "resume-monitoring-canary-role"

  lifecycle {
    ignore_errors = true
  }
}

resource "aws_iam_role" "canary_role" {
  count               = data.aws_iam_role.existing_canary_role.id != "" ? 0 : 1
  name                = "resume-monitoring-canary-role"
  assume_role_policy  = data.aws_iam_policy_document.assume_synthetics.json

  lifecycle {
    prevent_destroy = true
  }
}

locals {
  canary_role_arn  = length(aws_iam_role.canary_role) == 1
    ? aws_iam_role.canary_role[0].arn
    : data.aws_iam_role.existing_canary_role.arn

  canary_role_name = length(aws_iam_role.canary_role) == 1
    ? aws_iam_role.canary_role[0].name
    : data.aws_iam_role.existing_canary_role.name
}

data "aws_iam_policy_document" "canary_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "synthetics:CreateCanary",
      "synthetics:StartCanary",
      "s3:GetObject",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "canary_policy" {
  role   = local.canary_role_name
  policy = data.aws_iam_policy_document.canary_policy.json
}
