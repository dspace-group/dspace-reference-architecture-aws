locals {
  buckets            = { for b in var.buckets : b.name => b if b.create }
  bucket_arns        = [for b in var.buckets : "arn:aws:s3:::${b.name}"]
  bucket_object_arns = [for b in var.buckets : "arn:aws:s3:::${b.name}/*"]
  logged_buckets     = { for k, b in local.buckets : k => b if b.logging }
  versioned_buckets  = { for k, b in local.buckets : k => b if b.versioning }
  master_user_secret = var.opensearch.enable ? jsondecode(data.aws_secretsmanager_secret_version.opensearch_secret[0].secret_string) : null
  s3_access_sa_name  = "${var.identifier}-sa"
}
