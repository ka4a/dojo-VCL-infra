variable "vpc_id" {}
variable "environment" {}
variable "security_group_ids" {
  default = []
}

variable "name_prefix" {}

variable "redis_node_type" {
  default = "cache.t3.micro"
}
variable "redis_version" {
  default = "6.x"
}
variable "redis_parameter_group_name" {
  default = "default.redis6.x"
}
variable "redis_port" {
  default = 6379
}

variable "private_net_ids" {
  type        = list(any)
  description = "List of IDs of private subnets"
}

variable "vpc_cidr" {
  default = ""
}

variable "tags" {
  default = {}
}

variable "cluster_id" {
  default = ""
}
