locals {
  name_prefix         = "${var.function_name}-${var.env}"
  account_id          = data.aws_caller_identity.current.account_id
  region              = data.aws_region.current.name
  lambda_package_name = "${local.name_prefix}.zip"
}
