locals {
  name_prefix = "${var.project}-${var.env}"

  domain = "dojocodelab.com"

  subnet_cidr_public_a  = "10.0.0.0/20"
  subnet_cidr_public_c  = "10.0.16.0/20"
  subnet_cidr_private_a = "10.0.128.0/20"
  subnet_cidr_private_c = "10.0.144.0/20"
  vpc_cidr              = "10.0.0.0/16"

  tags = {
    "Env"           = var.env
    "Orchestration" = "Terraform"
    "Project"       = upper(var.project)
  }
}
