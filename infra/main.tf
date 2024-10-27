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


module "s3_documents_storage" {
  source = "./modules/s3"

  bucket_name       = "learnd-documents-bucket"
  enable_versioning = true
  force_destroy     = true
  environment       = var.environment
}

module "dynamodb_documents_metadata" {
  source = "./modules/dynamodb"

  table_name = "Learnd_Documents_Metadata"
  hash_key   = "ID"

  attributes = [
    { name = "ID", type = "S" },
  ]

  global_secondary_indexes = []
}

data "archive_file" "document_processor_lambda" {
  type        = "zip"
  source_file = "${path.module}/../lambda/DocumentProcessor/processor.py"
  output_path = "document_processor_function_src.zip"
}
module "documents_process_lambda" {
  source = "./modules/lambda"

  filename         = data.archive_file.document_processor_lambda.output_path
  source_code_hash = data.archive_file.document_processor_lambda.output_base64sha256
  role_name        = "document_process_lambda_role"
  function_name    = "document_processor"
  runtime          = "python3.9"
  handler_function = "lambda_handler"
  environment      = var.environment
}
