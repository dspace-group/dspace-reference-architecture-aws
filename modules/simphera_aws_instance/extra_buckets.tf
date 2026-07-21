locals {
  extra_buckets_map          = { for bucket in var.extra_buckets : bucket.name => bucket }
  buckets_s3_lifecycle_rules = { for bucket in var.extra_buckets : bucket.name => bucket if bucket.s3_lifecycle_rules != null }
}

resource "aws_s3_bucket" "extra" {
  for_each      = local.extra_buckets_map
  bucket        = each.value.name
  tags          = var.tags
  force_destroy = var.enable_deletion_protection ? false : true
}

resource "aws_s3_bucket_cors_configuration" "extra" {
  for_each = var.simphera_url != null ? aws_s3_bucket.extra : {}
  bucket   = each.value.id

  cors_rule {
    id              = "simphera-access"
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = [var.simphera_url]
    allowed_headers = ["Authorization"]
    expose_headers  = ["Access-Control-Allow-Origin"]
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "extra" {
  for_each = local.buckets_s3_lifecycle_rules
  bucket   = each.value.name

  dynamic "rule" {
    for_each = each.value.s3_lifecycle_rules
    content {
      id     = rule.value.id
      status = "Enabled"
      filter {
        prefix = rule.value.path
      }
      expiration {
        days                         = rule.value.expiration_days
        expired_object_delete_marker = true
      }
      noncurrent_version_expiration {
        noncurrent_days = rule.value.expiration_days
      }
    }
  }
  depends_on = [aws_s3_bucket.extra]
}

resource "aws_s3_bucket_versioning" "extra" {
  for_each = aws_s3_bucket.extra
  bucket   = each.value.id
  versioning_configuration {
    status = "Enabled"
  }
}

# [S3.4] S3 buckets should have server-side encryption enabled
resource "aws_s3_bucket_server_side_encryption_configuration" "extra" {
  for_each = aws_s3_bucket.extra
  bucket   = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

# [S3.8] S3 Block Public Access setting should be enabled at the bucket level
resource "aws_s3_bucket_public_access_block" "extra" {
  for_each = aws_s3_bucket.extra
  bucket   = each.value.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# [S3.5] S3 buckets should require requests to use Secure Socket Layer
resource "aws_s3_bucket_policy" "extra_ssl" {
  for_each = aws_s3_bucket.extra
  bucket   = each.value.id
  policy   = templatefile("${path.module}/templates/bucket_ssl_policy.json", { bucket = each.value.id })
}

resource "aws_iam_policy" "extra_access" {
  for_each    = aws_s3_bucket.extra
  name        = "${each.value.id}-extra-s3-policy"
  description = "Allows access to S3 bucket."
  policy      = templatefile("${path.module}/templates/bucket_access_policy.json", { bucket = each.value.id })
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "extra_minio" {
  for_each   = var.enable_minio ? aws_s3_bucket.extra : {}
  role       = aws_iam_role.minio_irsa[0].name
  policy_arn = aws_iam_policy.extra_access[each.value.id].arn
}

resource "aws_iam_role_policy_attachment" "extra_simphera" {
  for_each   = var.enable_minio ? {} : aws_s3_bucket.extra
  role       = aws_iam_role.simphera_irsa[0].name
  policy_arn = aws_iam_policy.extra_access[each.value.id].arn
}

resource "aws_iam_role_policy_attachment" "extra_executoragentlinux" {
  for_each   = var.enable_minio ? {} : aws_s3_bucket.extra
  role       = aws_iam_role.executoragentlinux_irsa[0].name
  policy_arn = aws_iam_policy.extra_access[each.value.id].arn
}
