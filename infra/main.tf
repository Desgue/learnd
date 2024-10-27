terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }

  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region     = var.AWS_REGION
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

# S3 MODULE
module "s3_documents_storage" {
  source = "./modules/s3"

  bucket_name       = "learnd-documents-bucket"
  enable_versioning = true
  force_destroy     = true
  environment       = var.environment
}

# DYNAMODB MODULE
module "dynamodb_documents_metadata" {
  source = "./modules/dynamodb"

  table_name = "Learnd_Documents_Metadata"
  hash_key   = "ID"

  attributes = [
    { name = "ID", type = "S" },
  ]

  global_secondary_indexes = []
}

# CONTAINER REGISTRY MODULE
module "document_process_lambda_registry" {
  source = "./modules/ecr"

  repository_name = "document_processer"
}

# Lambda Function Triggered by S3
module "documents_process_lambda" {
  source = "./modules/lambda"

  image_uri        = "${module.document_process_lambda_registry.repository_url}:latest"
  role_name        = "document_process_lambda_role"
  function_name    = "document_processor"
  runtime          = "python3.9"
  handler_function = "processor.lambda_handler"
  environment      = var.environment
}

// Add processor lambda trigger to documents bucket
// TODO: add event for object updated?
resource "aws_s3_bucket_notification" "lambda-processor-trigger" {
  bucket = module.s3_documents_storage.bucket_id
  lambda_function {
    lambda_function_arn = module.documents_process_lambda.lambda_arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
  depends_on = [aws_lambda_permission.document_processor_permission]
}
resource "aws_lambda_permission" "document_processor_permission" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = module.documents_process_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${module.s3_documents_storage.bucket_id}"
}
