resource "aws_lambda_function" "this" {
  description   = "Mock LTI consumer function"
  function_name = local.name_prefix
  role          = (var.create_function_role && (var.function_role != null)) ? var.function_role : aws_iam_role.this.arn
  handler       = var.handler
  s3_bucket     = aws_s3_bucket.this.id
  s3_key        = local.lambda_package_name
  runtime       = "python3.9"
  timeout       = 120

  environment {
    variables = {
      WEB_ADDRESS  = var.backend_address
      MOCK_ADDRESS = "change.me" #Since Function URL is know after Lambda is created it's required to update the value manually
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [environment]
  }

  depends_on = [
    aws_s3_bucket.this,
    aws_iam_role.this,
    aws_iam_role_policy_attachment.this
  ]
}

resource "aws_lambda_function_url" "this" {
  authorization_type = "NONE"
  function_name      = aws_lambda_function.this.arn
}
