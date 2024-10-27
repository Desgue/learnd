resource "aws_s3_bucket" "bucket" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_cors_configuration" "bucket_cors_policy" {
  bucket = aws_s3_bucket.bucket.id

  // TODO: Make cors configuration configurable via variables?
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "DELETE"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
    expose_headers  = []
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_server_side_encryption" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}
