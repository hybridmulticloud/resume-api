data "aws_iam_role" "lambda_exec" {
  name = var.lambda_exec_role_name
}

data "aws_lambda_function" "update_visitor_count" {
  function_name = var.lambda_function_name
}

data "aws_dynamodb_table" "visitor_count" {
  name = var.dynamodb_table_name
}
