variable "env" {
  description = "Environment name."
  type        = string
  default     = "test"
}

variable "function_name" {
  description = "Unique name for your Lambda Function."
  type        = string
  default     = "vcl-mock-lti"
}

variable "create_function_role" {
  description = "Whether to create execution role for Lambda function."
  type        = bool
  default     = true
}

variable "function_role" {
  description = "Amazon Resource Name (ARN) of the function's execution role. The role provides the function's identity and access to AWS services and resources."
  type        = string
  default     = null
}

variable "handler" {
  description = "Lambda function handler"
  type        = string
  default     = "app.handler"
}

variable "backend_address" {
  description = "The value of WEB_ADDRESS function's environment variable"
  type        = string
  default     = "https://testing.dojocodelab.com"
}

variable "tags" {
  description = "Key-value map of tags"
  type        = map(string)
}
