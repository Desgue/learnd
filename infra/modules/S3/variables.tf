variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}
variable "enable_versioning" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = true
}
variable "force_destroy" {
  description = "Enable force destroy for the s3 bucket"
  type        = bool
  default     = false
}
variable "environment" {
  description = "Variable to define if its a production or development environment tag"
  type        = string
}
