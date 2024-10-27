
variable "role_name" {
  description = "The name of the IAM role for the Lambda function"
  type        = string
}

variable "function_name" {
  description = "The name of the lambda function"
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

variable "image_uri" {
  description = "The path for the lambda docker image"
  type        = string
}
