# Trust policy for Synthetics
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

# Canary execution role
resource "aws_iam_role" "canary" {
  name               = "${var.project_name}-canary-role"
  assume_role_policy = data.aws_iam_policy_document.canary_assume.json
  tags               = var.tags
}

# Attach AWS-managed Synthetics policy
resource "aws_iam_role_policy_attachment" "synthetics_core" {
  role       = aws_iam_role.canary.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchSyntheticsFullAccess"
}

# S3 access for code & artifacts
data "aws_iam_policy_document" "canary_s3" {
  statement {
    effect = "Allow"
    actions = [
      "s3:CreateBucket",
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "s3:GetBucketAcl",
      "s3:GetBucketCors",
      "s3:GetBucketPolicy",
      "s3:GetBucketVersioning",
      "s3:GetBucketWebsite",
      "s3:GetEncryptionConfiguration",
      "s3:PutBucketAcl",
      "s3:PutBucketCors",
      "s3:PutBucketPolicy",
      "s3:PutBucketWebsite",
      "s3:PutBucketVersioning",
      "s3:PutEncryptionConfiguration",
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      aws_s3_bucket.canary_artifacts.arn,
      "${aws_s3_bucket.canary_artifacts.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "canary_s3_policy" {
  name   = "${var.project_name}-canary-s3"
  policy = data.aws_iam_policy_document.canary_s3.json
}

resource "aws_iam_role_policy_attachment" "canary_s3_attach" {
  role       = aws_iam_role.canary.name
  policy_arn = aws_iam_policy.canary_s3_policy.arn
}
