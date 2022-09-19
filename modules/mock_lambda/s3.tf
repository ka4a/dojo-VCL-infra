resource "aws_s3_bucket" "this" {
  bucket = "${local.name_prefix}-lambda-source"

  tags = var.tags
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = "${local.name_prefix}-lambda-source"

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "this" {
  bucket = "${local.name_prefix}-lambda-source"
  key    = local.lambda_package_name

  depends_on = [
    aws_s3_bucket.this
  ]
}
