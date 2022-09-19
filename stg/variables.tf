variable "thumbprint" {
  description = "thumbprint value"
  default     = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

variable "github_repo" {
  description = "GitHub repository to grant access to. Format: {Organization}/{Repo}"
  default     = ["repo:reustleco/dojo-VCL-infra:*", "repo:reustleco/dojo-vcl:*", "repo:reustleco/dojo-vcl-images:*"]
}

variable "account_id" {
  description = "AWS Account ID for this environment."
  default     = "762006128434"
}

variable "ecr_allow_pull_entities" {
  type    = string
  default = "arn:aws:iam::762006128434:root"
}

variable "ecr_allow_push_entities" {
  type    = string
  default = "arn:aws:iam::762006128434:user/vcl_ecr_pusher"
}

variable "env" {
  type        = string
  description = "Environment name"
  default     = "stg"
}

variable "project" {
  type    = string
  default = "vcl"
}

variable "vcl_web_sub_domain_name" {
  type    = string
  default = "staging"
}

variable "domain_name" {
  type    = string
  default = "dojocodelab.com"
}

variable "rabbit_password" {
  type        = string
  description = "Rabbit Password"
  sensitive   = true

  validation {
    condition     = length(var.rabbit_password) > 7
    error_message = "The pg_password value must be minimum length of 8 characters."
  }
}

variable "pg_password" {
  type        = string
  description = "RDS Postgres Password"
  sensitive   = true

  validation {
    condition     = length(var.pg_password) > 7
    error_message = "The pg_password value must be minimun lenght of 8 characters."
  }
}
