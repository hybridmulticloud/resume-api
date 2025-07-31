data "archive_file" "api_canary" {
  type        = "zip"
  source_dir  = "${path.module}/canaries/api"
  output_path = "${path.module}/canaries/api.zip"
}

data "archive_file" "homepage_canary" {
  type        = "zip"
  source_dir  = "${path.module}/canaries/homepage"
  output_path = "${path.module}/canaries/homepage.zip"
}

resource "aws_s3_object" "api_zip" {
  depends_on = [null_resource.bucket_ready]
  bucket     = local.bucket_name
  key        = "${local.api_canary_name}.zip"
  source     = data.archive_file.api_canary.output_path
  etag       = filemd5(data.archive_file.api_canary.output_path)
}

resource "aws_s3_object" "homepage_zip" {
  depends_on = [null_resource.bucket_ready]
  bucket     = local.bucket_name
  key        = "${local.homepage_canary_name}.zip"
  source     = data.archive_file.homepage_canary.output_path
  etag       = filemd5(data.archive_file.homepage_canary.output_path)
}

resource "aws_synthetics_canary" "api" {
  depends_on          = [aws_s3_object.api_zip]
  name                = local.api_canary_name
  execution_role_arn  = aws_iam_role.canary.arn
  runtime_version     = "syn-nodejs-puppeteer-10.0"
  handler             = "index.handler"
  s3_bucket           = local.bucket_name
  s3_key              = aws_s3_object.api_zip.key
  artifact_s3_location = "s3://${local.bucket_name}/api"

  schedule {
    expression = var.schedule_expression
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = local.tags
}

resource "aws_synthetics_canary" "homepage" {
  depends_on          = [aws_s3_object.homepage_zip]
  name                = local.homepage_canary_name
  execution_role_arn  = aws_iam_role.canary.arn
  runtime_version     = "syn-python-selenium-5.1"
  handler             = "pageLoadBlueprint.handler"
  s3_bucket           = local.bucket_name
  s3_key              = aws_s3_object.homepage_zip.key
  artifact_s3_location = "s3://${local.bucket_name}/homepage"

  schedule {
    expression = var.schedule_expression
  }

  tags = local.tags
}
