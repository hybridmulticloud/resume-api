data "aws_iam_policy_document" "assume_synthetics" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["synthetics.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "canary_role" {
  name               = "resume-monitoring-canary-role"
  assume_role_policy = data.aws_iam_policy_document.assume_synthetics.json

  lifecycle {
    prevent_destroy = true
  }
}

data "aws_iam_policy_document" "canary_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "synthetics:CreateCanary",
      "synthetics:StartCanary",
      "s3:GetObject"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "canary_policy" {
  role   = aws_iam_role.canary_role.id
  policy = data.aws_iam_policy_document.canary_policy.json
}
