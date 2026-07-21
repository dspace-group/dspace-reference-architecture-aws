locals {
  all_buckets = toset(concat(var.data_bucket.create ? [aws_s3_bucket.data_bucket[0].id] : [], var.raw_data_bucket.create ? [aws_s3_bucket.rawdata_bucket[0].id] : []))
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  for_each = local.all_buckets
  bucket   = each.value

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "buckets_access" {
  for_each = local.all_buckets
  bucket   = each.value

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  for_each = local.all_buckets
  bucket   = each.value
  policy   = templatefile("templates/s3_ssl_policy.json", { bucket = each.value })

}
