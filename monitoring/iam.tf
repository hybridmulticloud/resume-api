data "aws_iam_policy_document" "canary_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = [
        "synthetics.amazonaws.com",
        "lambda.amazonaws.com",
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "canary" {
  name               = "resume-api-canary-role"
  assume_role_policy = data.aws_iam_policy_document.canary_assume.json
  tags               = local.tags
}

resource "aws_iam_policy" "canary_s3" {
  name   = "resume-api-canary-s3-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "S3FullLifecycleForCanaryArtifacts",
        Effect = "Allow",
        Action = [
          "s3:Get*",
          "s3:List*",
          "s3:PutBucketAcl",
          "s3:PutBucketCors",
          "s3:PutBucketPolicy",
          "s3:PutBucketWebsite",
          "s3:PutBucketVersioning",
          "s3:PutBucketTagging",
          "s3:PutBucketLogging",
          "s3:PutEncryptionConfiguration",
          "s3:PutObject"
        ],
        Resource = [
          "arn:aws:s3:::resume-api-*-canary-artifacts",
          "arn:aws:s3:::resume-api-*-canary-artifacts/*"
        ]
      },
      {
        Sid    = "S3ReadCanaryLibraries",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ],
        Resource = [
          "arn:aws:s3:::aws-synthetics-library-*",
          "arn:aws:s3:::aws-synthetics-library-*/*"
        ]
      },
      {
        Sid    = "S3WriteResults",
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        Resource = ["arn:aws:s3:::cw-syn-results-*/*"]
      },
      {
        Sid    = "LambdaPublishVersion",
        Effect = "Allow",
        Action = ["lambda:PublishVersion"],
        Resource = ["arn:aws:lambda:*:*:function:cwsyn-resume-api-*"]
      },
      {
        Sid    = "LambdaAddPermissionForCanaries",
        Effect = "Allow",
        Action = ["lambda:AddPermission"],
        Resource = ["arn:aws:lambda:*:*:function:cwsyn-resume-api-*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "synthetics_full" {
  role       = aws_iam_role.canary.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchSyntheticsFullAccess"
}

resource "aws_iam_role_policy_attachment" "canary_s3_attach" {
  role       = aws_iam_role.canary.name
  policy_arn = aws_iam_policy.canary_s3.arn
}
