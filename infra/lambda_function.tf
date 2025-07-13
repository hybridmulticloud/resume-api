resource "aws_lambda_function" "update_visitor_count" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_exec.arn
  handler       = "update_visitor_count.lambda_handler"
  runtime       = var.lambda_runtime

  filename         = "lambda_stub.zip"
  source_code_hash = filebase64sha256("lambda_stub.zip")

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name
    }
  }

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_exec,
    aws_iam_role_policy.lambda_inline_dynamodb
  ]
}
