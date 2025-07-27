data "aws_iam_policy_document" "assume_synthetics" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["synthetics.amazonaws.com"]
    }
  }
}

data "external" "canary_role_lookup" {
  program = [
    "bash", "-c",
    <<-EOC
      aws iam get-role \
        --role-name ${var.role_name} \
        --query '{role_name:Role.RoleName, arn:Role.Arn}' \
        --output json 2>/dev/null || echo '{\"role_name\": \"\"}'
    EOC
  ]
}

locals {
  role_exists = length(data.external.canary_role_lookup.result.role_name) > 0
}

resource "aws_iam_role" "canary_role" {
  count              = local.role_exists ? 0 : 1
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_synthetics.json

  lifecycle {
    prevent_destroy = true
  }
}

locals {
  canary_role_name = local.role_exists
    ? data.external.canary_role_lookup.result.role_name
    : aws_iam_role.canary_role[0].name

  canary_role_arn = local.role_exists
    ? data.external.canary_role_lookup.result.arn
    : aws_iam_role.canary_role[0].arn
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
