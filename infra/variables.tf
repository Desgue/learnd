variable "AWS_SECRET_ACCESS_KEY" {
  type = string
}
variable "AWS_ACCESS_KEY_ID" {
  type = string
}
variable "AWS_REGION" {
  type    = string
  default = "eu-west-2"
}
variable "environment" {
  description = "Variable to define if its a production or development environment tag"
  type        = string
  default     = "development"
}
