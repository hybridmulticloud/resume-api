provider "aws" {
  region = var.aws_region
}

# Upload zipped Lambda to S3
resource "aws_s3_bucket_object" "lambda_zip" {
  bucket = "resume-api-lambda-bucket"
  key    = "lambda.zip"
  source = "${path.module}/lambda.zip"
  etag   = filemd5("${path.module}/lambda.zip")
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach basic execution policy
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function
resource "aws_lambda_function" "update_visitor_count" {
  function_name = "UpdateVisitorCount"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.10"

  s3_bucket         = "resume-api-lambda-bucket"
  s3_key            = aws_s3_bucket_object.lambda_zip.key
  source_code_hash  = filebase64sha256("${path.module}/lambda.zip")

  depends_on = [aws_iam_role_policy_attachment.lambda_policy_attach]
}

# DynamoDB Table
resource "aws_dynamodb_table" "visitor_count" {
  name         = "visitor_count"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# Null resource to seed table (only if item is missing)
resource "null_resource" "seed_dynamodb" {
  provisioner "local-exec" {
    command = <<EOT
      echo "Checking if DynamoDB item exists..."

      ITEM_EXISTS=$(aws dynamodb get-item \
        --table-name visitor_count \
        --key '{"id": {"S": "count"}}' \
        --region ${var.aws_region} \
        --query 'Item.id.S' \
        --output text 2>/dev/null)

      if [ "$ITEM_EXISTS" = "count" ]; then
        echo "Item already exists — skipping insert."
      else
        echo "Item missing — inserting initial count..."
        aws dynamodb put-item \
          --table-name visitor_count \
          --item '{"id": {"S": "count"}, "visits": {"N": "0"}}' \
          --region ${var.aws_region}
      fi
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  triggers = {
    always_run = uuid()
  }

  depends_on = [aws_dynamodb_table.visitor_count]
}

# API Gateway setup
resource "aws_apigatewayv2_api" "lambda_api" {
  name          = "VisitorCounterAPI"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                = aws_apigatewayv2_api.lambda_api.id
  integration_type      = "AWS_PROXY"
  integration_uri       = aws_lambda_function.update_visitor_count.invoke_arn
  integration_method    = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.lambda_api.id
  route_key = "POST /UpdateVisitorCount"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.lambda_api.id
  name        = "$default"
  auto_deploy = true
}

# Lambda permission for API Gateway to invoke
resource "aws_lambda_permission" "apigw_invoke_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_visitor_count.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
}
