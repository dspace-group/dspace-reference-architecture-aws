resource "aws_s3_bucket" "docker_images_archive" {
  count  = var.dockerImagesArchive.enable ? 1 : 0
  bucket = var.dockerImagesArchive.bucket_name
  tags   = var.tags
}

# https://docs.aws.amazon.com/config/latest/developerguide/s3-bucket-ssl-requests-only.html
resource "aws_s3_bucket_policy" "docker_images_archive_ssl" {
  count  = var.dockerImagesArchive.enable ? 1 : 0
  bucket = aws_s3_bucket.docker_images_archive[0].id
  policy = templatefile("templates/s3_ssl_policy.json", { bucket = aws_s3_bucket.docker_images_archive[0].id })
}

resource "aws_s3_bucket_public_access_block" "docker_images_archive_bucket_public_access" {
  count  = var.dockerImagesArchive.enable ? 1 : 0
  bucket = aws_s3_bucket.docker_images_archive[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "docker_images_archive_bucket" {
  count  = var.dockerImagesArchive.enable ? 1 : 0
  bucket = aws_s3_bucket.docker_images_archive[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}
