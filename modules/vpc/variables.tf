# General variables
####

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "name_prefix" {}

# Variables for VPC
######################################

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "vpc_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

# Variables for Subnet
######################################

variable "subnet_cidr_public_a" {}

variable "subnet_cidr_public_c" {}

variable "subnet_cidr_private_a" {}

variable "subnet_cidr_private_c" {}

# Variables for Security Group
######################################

variable "allowed_ips" {
  type    = list(string)
  default = []
}
