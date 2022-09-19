#-----------------------------------------------------------
# Global or/and default variables
#-----------------------------------------------------------
variable "name" {
  description = "Name to be used on all resources as prefix"
  default     = ""
}

variable "tags" {
  description = "A list of tag blocks. Each element should have keys named key, value, and propagate_at_launch."
  type        = map(string)
  default     = {}
}

#-----------------------------------------------------------
# ECR repo
#-----------------------------------------------------------
variable "enable_ecr_repository" {
  description = "Enable ecr repo creating"
  default     = false
}

#-----------------------------------------------------------
# ECR repo policy
#-----------------------------------------------------------
variable "enable_ecr_repository_policy" {
  description = "Enable ecr repo policy usage"
  default     = false
}

variable "ecr_repository_policy" {
  description = "Json file with policy"
  default     = ""
}

#-----------------------------------------------------------
# ECR lifecycle policy
#-----------------------------------------------------------
variable "enable_ecr_lifecycle_policy" {
  description = "Enable ecr lifecycle policy"
  default     = false
}

variable "ecr_lifecycle_policy" {
  description = "Json file with lifecycle policy"
  default     = ""
}
