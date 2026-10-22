resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Demonstration storage buckets; this does NOT implement image processing.
resource "aws_s3_bucket" "demo" {
  for_each = toset(["raw", "finished"])

  bucket        = "${var.project_name}-${each.key}-${random_id.bucket_suffix.hex}"
  force_destroy = false

  tags = {
    Purpose = each.key
  }
}

resource "aws_s3_bucket_public_access_block" "demo" {
  for_each = aws_s3_bucket.demo

  bucket                  = each.value.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "demo" {
  for_each = aws_s3_bucket.demo

  bucket = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
