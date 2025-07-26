# Create an S3 bucket for storing canary artifacts (screenshots/logs)
resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "canary_artifacts" {
  bucket        = "canary-artifacts-${random_id.suffix.hex}"
  acl           = "private"
  force_destroy = true

  tags = {
    Name = "CanaryArtifacts"
  }
}
