resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.project_name}-lambda-bucket"
  acl    = "private"

  tags = {
    Project     = var.project_name
    Environment = "Production"
    System      = "LambdaArtifacts"
  }
}

resource "aws_s3_bucket_versioning" "lambda_zip" {
  bucket = aws_s3_bucket.lambda_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "${var.project_name}-lambda-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_exec" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_dynamodb" {
  name = "${var.project_name}-dynamodb-access"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["dynamodb:UpdateItem", "dynamodb:GetItem"]
      Resource = "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.dynamodb_table_name}"
    }]
  })
}

resource "aws_dynamodb_table" "visitor_count" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "null_resource" "seed_dynamodb" {
  triggers = { always_run = uuid() }

  provisioner "local-exec" {
    command = <<EOT
ITEM=$(aws dynamodb get-item \
  --table-name ${var.dynamodb_table_name} \
  --key '{"id":{"S":"count"}}' \
  --region ${data.aws_region.current.name} \
  --query 'Item.id.S' \
  --output text 2>/dev/null)
if [ "$ITEM" != "count" ]; then
  aws dynamodb put-item \
    --table-name ${var.dynamodb_table_name} \
    --item '{"id":{"S":"count"},"visits":{"N":"0"}}' \
    --region ${data.aws_region.current.name}
fi
EOT
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [aws_dynamodb_table.visitor_count]
}

resource "aws_apigatewayv2_api" "lambda_api" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["https://${var.frontend_domain}"]
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["content-type"]
    max_age       = 3600
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.lambda_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.update_visitor_count.invoke_arn
  integration_method     = "POST"
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

  default_route_settings {
    throttling_burst_limit = 5000
    throttling_rate_limit  = 10000
  }
}

resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_visitor_count.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
}
