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


module "s3_pdf_storage" {
  source = "./modules/s3"

  bucket_name       = "learnd-pdf"
  enable_versioning = true
  force_destroy     = true
}

module "dynamodb_pdf_metadata" {
  source = "./modules/dynamodb"

  table_name = "Learnd_PDF_Metadata"
  hash_key   = "ID"

  attributes = [
    { name = "ID", type = "S" },
  ]

  global_secondary_indexes = []
}
