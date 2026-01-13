
resource "aws_s3_bucket" "bucket" {
  bucket        = local.instancename
  tags          = var.tags
  force_destroy = var.enable_deletion_protection ? false : true
}

resource "aws_s3_bucket_logging" "logging" {
  bucket = aws_s3_bucket.bucket.id
  #[S3.9] S3 bucket server access logging should be enabled
  target_bucket = var.log_bucket
  target_prefix = "logs/bucket/${aws_s3_bucket.bucket.id}/"
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# [S3.4] S3 buckets should have server-side encryption enabled
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

# [S3.8] S3 Block Public Access setting should be enabled at the bucket level
resource "aws_s3_bucket_public_access_block" "bucket_access_block" {
  bucket = aws_s3_bucket.bucket.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# [S3.5] S3 buckets should require requests to use Secure Socket Layer
resource "aws_s3_bucket_policy" "buckets_ssl" {
  bucket = aws_s3_bucket.bucket.bucket
  policy = templatefile("${path.module}/templates/bucket_ssl_policy.json", { bucket = aws_s3_bucket.bucket.bucket })
}

resource "aws_iam_policy" "bucket_access" {
  name        = "${local.instancename}-s3-policy"
  description = "Allows access to S3 bucket."
  policy      = templatefile("${path.module}/templates/bucket_access_policy.json", { bucket = local.instancename })
  tags        = var.tags
}

resource "aws_iam_role" "minio_irsa" {
  count       = var.enable_minio ? 1 : 0
  name        = "${local.instancename}-minio-role"
  description = "IAM role for the MinIO service account"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : var.eks_oidc_provider_arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${local.eks_oidc_issuer}:sub" : "system:serviceaccount:${var.k8s_namespace}:${local.minio_serviceaccount}"
          }
        }
      }
    ]
  })
  tags = var.tags
}

resource "aws_iam_role" "simphera_irsa" {
  count       = var.enable_minio ? 0 : 1
  name        = "${var.name}-simphera-irsa-role"
  description = "IAM role for the simphera-irsa service account"
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : var.eks_oidc_provider_arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${local.eks_oidc_issuer}:sub" : "system:serviceaccount:${var.k8s_namespace}:simphera-irsa"
          }
        }
      }
    ]
  })
  tags = var.tags
}

resource "aws_iam_role" "executoragentlinux_irsa" {
  count       = var.enable_minio ? 0 : 1
  name        = "${var.name}-executoragentlinux-irsa-role"
  description = "IAM role for the executoragentlinux-irsa service account"
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : var.eks_oidc_provider_arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${local.eks_oidc_issuer}:sub" : "system:serviceaccount:${var.k8s_namespace}:executoragentlinux-irsa"
          }
        }
      }
    ]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "minio" {
  count      = var.enable_minio ? 1 : 0
  role       = aws_iam_role.minio_irsa.name
  policy_arn = aws_iam_policy.bucket_access.arn
}

resource "aws_iam_role_policy_attachment" "simphera" {
  count      = var.enable_minio ? 0 : 1
  role       = aws_iam_role.simphera_irsa.name
  policy_arn = aws_iam_policy.bucket_access.arn
}

resource "aws_iam_role_policy_attachment" "executoragentlinux" {
  count      = var.enable_minio ? 0 : 1
  role       = aws_iam_role.executoragentlinux_irsa.name
  policy_arn = aws_iam_policy.bucket_access.arn
}
