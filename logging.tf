# Logging S3 bucket and related resources for the infrastructure
resource "aws_s3_bucket" "logs_bucket" {
  bucket        = "${var.infrastructure_name}-logs"
  tags          = var.tags
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "logs_bucket" {
  bucket                  = aws_s3_bucket.logs_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "logs_bucket" {
  bucket = aws_s3_bucket.logs_bucket.bucket
  policy = jsonencode(local.log_bucket_policy)
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs_bucket" {
  bucket = aws_s3_bucket.logs_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.aws_managed_kms ? null : aws_kms_key.s3_logs_key[0].arn
    }
  }
}

resource "aws_kms_key" "s3_logs_key" {
  count               = var.aws_managed_kms ? 0 : 1
  description         = "KMS key for encrypting S3 access logs"
  enable_key_rotation = true
  tags                = var.tags
  policy              = <<POLICY
  {
    "Version" : "2012-10-17",
    "Id"      : "s3-logs-key-policy",
    "Statement" : [
      {
        "Sid"    : "AllowRootAccountFullAccess",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${local.aws_context.caller_identity_account_id}:root"
        },
        "Action"   : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid"    : "AllowS3LoggingServiceToEncrypt",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "logging.s3.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "aws:SourceAccount" : "${local.aws_context.caller_identity_account_id}"
          }
        }
      }
    ]
  }
  POLICY
}

resource "aws_kms_key" "cloudwatch_log_group" {
  count               = var.aws_managed_kms ? 0 : 1
  description         = "KMS key used to encrypt Kubernetes, VPC Flow, Amazon RDS for PostgreSQL and SSM Patch manager log groups within infrastructure ${var.infrastructure_name}"
  enable_key_rotation = true
  tags                = var.tags
  policy              = <<-POLICY
    {
        "Version": "2012-10-17",
        "Id": "key-default-1",
        "Statement": [
            {
                "Sid": "Enable IAM User Permissions",
                "Effect": "Allow",
                "Principal": {
                    "AWS": "arn:aws:iam::${local.aws_context.caller_identity_account_id}:root"
                },
                "Action": "kms:*",
                "Resource": "*"
            },
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "logs.${local.aws_context.region_name}.amazonaws.com"
                },
                "Action": [
                    "kms:Encrypt*",
                    "kms:Decrypt*",
                    "kms:ReEncrypt*",
                    "kms:GenerateDataKey*",
                    "kms:Describe*"
                ],
                "Resource": "*",
                "Condition": {
                    "ArnLike": {
                        "kms:EncryptionContext:aws:logs:arn": "arn:aws:logs:${local.aws_context.region_name}:${local.aws_context.caller_identity_account_id}:*"
                    }
                }
            }
        ]
    }
    POLICY
}
