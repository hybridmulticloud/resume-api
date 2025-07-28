# … archive_file blocks unchanged …

resource "aws_s3_bucket_object" "api_zip" {
  bucket = local.bucket_name
  key    = "${local.api_canary_name}.zip"
  source = data.archive_file.api_canary.output_path
}

resource "aws_s3_bucket_object" "homepage_zip" {
  bucket = local.bucket_name
  key    = "${local.homepage_canary_name}.zip"
  source = data.archive_file.homepage_canary.output_path
}

resource "aws_synthetics_canary" "api" {
  # …
  s3_bucket = local.bucket_name
  s3_key    = aws_s3_bucket_object.api_zip.key
  # …
}

resource "aws_synthetics_canary" "homepage" {
  # …
  s3_bucket = local.bucket_name
  s3_key    = aws_s3_bucket_object.homepage_zip.key
  # …
}
