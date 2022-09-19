resource "aws_s3_bucket" "s3bucket" {
  bucket = var.s3bucket_name
  acl    = "private"

  versioning {
    enabled = false
  }
}
