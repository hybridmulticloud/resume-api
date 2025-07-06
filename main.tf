provider "aws" { 
}

# S3 Bucket for Lambda ZIP
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.project_name}-lambda-bucket"
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "${var.project_name}-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach execution policy
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function
resource "aws_lambda_function" "update_visitor_count" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = var.lambda_runtime

  s3_bucket         = aws_s3_bucket.lambda_bucket.bucket
  s3_key            = aws_s3_bucket_object.lambda_zip.key
  source_code_hash  = filebase64sha256("${path.module}/lambda_function.zip")

  depends_on = [aws_iam_role_policy_attachment.lambda_policy_attach]
}

# DynamoDB Table
resource "aws_dynamodb_table" "visitor_count" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# Safe seeding of DynamoDB table
resource "null_resource" "seed_dynamodb" {
  provisioner "local-exec" {
    command = <<EOT
      ITEM_EXISTS=$(aws dynamodb get-item \
        --table-name ${var.dynamodb_table_name} \
        --key '{"id": {"S": "count"}}' \
        --region $AWS_REGION \
        --query 'Item.id.S' \
        --output text 2>/dev/null)

      if [ "$ITEM_EXISTS" = "count" ]; then
        echo "Item already exists — skipping seed."
      else
        echo "Seeding table with initial count = 0"
        aws dynamodb put-item \
          --table-name ${var.dynamodb_table_name} \
          --item '{"id": {"S": "count"}, "visits": {"N": "0"}}' \
          --region $AWS_REGION
      fi
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  triggers = {
    always_run = uuid()
  }

  depends_on = [aws_dynamodb_table.visitor_count]
}

# API Gateway
resource "aws_apigatewayv2_api" "lambda_api" {
  name          = "${var.project_name}-api"
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

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "apigw_invoke_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
}
