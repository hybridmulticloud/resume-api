data "aws_iam_policy_document" "canary_assume" {
  statement {
    effect    = "Allow"
    principals {
      type        = "Service"
      identifiers = ["synthetics.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "canary" {
  name               = "${local.prefix}-canary-role"
  assume_role_policy = data.aws_iam_policy_document.canary_assume.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "synthetics_core" {
  role       = aws_iam_role.canary.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchSyntheticsFullAccess"
}

data "aws_iam_policy_document" "canary_s3" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket","s3:GetBucketAcl","s3:GetBucketLocation"]
    resources = [ aws_s3_bucket.canary_artifacts.arn ]
  }
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject","s3:GetObject"]
    resources = ["${aws_s3_bucket.canary_artifacts.arn}/*"]
  }
}

resource "aws_iam_policy" "canary_s3" {
  name   = "${local.prefix}-canary-s3-policy"
  policy = data.aws_iam_policy_document.canary_s3.json
}

resource "aws_iam_role_policy_attachment" "canary_s3_attach" {
  role       = aws_iam_role.canary.name
  policy_arn = aws_iam_policy.canary_s3.arn
}
