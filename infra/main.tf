provider "aws" {}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.project_name}-lambda-bucket"
}

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

resource "aws_iam_role_policy_attachment" "lambda_basic_exec" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_inline_dynamodb" {
  name = "inline-dynamodb-access"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:UpdateItem",
          "dynamodb:GetItem"
        ],
        Resource = "arn:aws:dynamodb:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:table/${var.dynamodb_table_name}"
      }
    ]
  })
}

  # This block enables Terraform to ignore source code updates
  filename         = null
  source_code_hash = null
  publish          = true

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name
    }
  }

  lifecycle {
    ignore_changes = [
      filename,
      source_code_hash
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_exec,
    aws_iam_role_policy.lambda_inline_dynamodb
  ]
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
  provisioner "local-exec" {
    command = <<EOT
      ITEM_EXISTS=$(aws dynamodb get-item         --table-name ${var.dynamodb_table_name}         --key '{"id": {"S": "count"}}'         --region ${data.aws_region.current.id}         --query 'Item.id.S'         --output text 2>/dev/null)

      if [ "$ITEM_EXISTS" = "count" ]; then
        echo "Item already exists — skipping seed."
      else
        echo "Seeding table with initial count = 0"
        aws dynamodb put-item           --table-name ${var.dynamodb_table_name}           --item '{"id": {"S": "count"}, "visits": {"N": "0"}}'           --region ${data.aws_region.current.id}
      fi
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  triggers = {
    always_run = uuid()
  }

  depends_on = [aws_dynamodb_table.visitor_count]
}

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

resource "aws_lambda_permission" "apigw_invoke_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
}
