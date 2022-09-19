variable "publicly_accessible" {
  default     = false
  description = "Public access for RDS"
}

variable "identifier" {
  default     = "mydb-rds"
  description = "Identifier for your DB"
}

variable "storage" {
  default     = "10"
  description = "Storage size in GB"
}

variable "engine" {
  default     = "postgres"
  description = "Engine type, example values mysql, postgres"
}

variable "engine_version" {
  description = "Engine version"

  default = {
    mysql    = "8.0.23"
    postgres = "13.5"
  }
}

variable "performance_insights_enabled" {
  default = false
}

variable "name_prefix" {}

variable "instance_class" {
  default     = "db.t3.micro"
  description = "Instance class"
}

variable "db_name" {
  default     = "mydb"
  description = "db name"
}

variable "username" {
  default     = "myuser"
  description = "User name"
}

variable "password" {
  description = "password, provide through your ENV variables"
}

variable "private_net_ids" {
  type        = list(any)
  description = "List of IDs of private subnets"
}

variable "environment" {}

variable "vpc_id" {}

variable "max_allocated_storage" {
  default = 100
}

variable "rds_security_group_id" {}

variable "tags" {
  default = {}
}
