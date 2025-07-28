data "aws_iam_policy_document" "canary_s3" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket","s3:GetBucketAcl","s3:GetBucketLocation"]
    resources = [ local.bucket_arn ]
  }
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject","s3:GetObject"]
    resources = [ local.bucket_arn_all ]
  }
}

resource "aws_iam_policy" "canary_s3_policy" {
  name   = "${local.prefix}-canary-s3-policy"
  policy = data.aws_iam_policy_document.canary_s3.json
}

resource "aws_iam_role_policy_attachment" "canary_s3" {
  role       = aws_iam_role.canary.name
  policy_arn = aws_iam_policy.canary_s3_policy.arn
}
