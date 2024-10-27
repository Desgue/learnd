
variable "role_name" {
  description = "The name of the IAM role for the Lambda function"
  type        = string
}


variable "filename" {
  description = "The file path for the zip lambda files"
  type        = string
}

variable "function_name" {
  description = "The name of the lambda function"
  type        = string
}
variable "source_code_hash" {
  description = "The hash of the lambda source code"
  type        = string
}
variable "runtime" {
  description = "The runtime environment to run the lambda function"
  type        = string
}

variable "handler_function" {
  description = "The handler function name"
  type        = string
}

variable "environment" {
  description = "Variable to define if its a production or development environment tag"
  type        = string
}
