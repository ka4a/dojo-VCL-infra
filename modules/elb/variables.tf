variable "acm_arn" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "fully_qualified_domain_name" {
  type = string
}

variable "name" {
  type = string
}

variable "env" {
  type = string
}

variable "internal" {
  type = bool
}

variable "r53_hosted_zone_private" {
  type    = bool
  default = false
}

variable "security_groups" {
  type = list(string)
}

variable "subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "tags" {
  type = map(string)
}
