resource "aws_s3_bucket" "bucket_logs" {
  bucket        = "${var.infrastructurename}-logs"
  tags          = var.tags
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "buckets_logs_access" {
  bucket                  = aws_s3_bucket.bucket_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "log_bucket_policy" {
  bucket = aws_s3_bucket.bucket_logs.bucket
  policy = jsonencode(local.log_bucket_policy)
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_logs_encryption" {
  bucket = aws_s3_bucket.bucket_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_logs_key.arn
    }
  }
}

resource "aws_kms_key" "s3_logs_key" {
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
          "AWS" : "arn:aws:iam::${local.account_id}:root"
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
            "aws:SourceAccount" : "${local.account_id}"
          }
        }
      }
    ]
  }
  POLICY
}


resource "aws_kms_key" "kms_key_cloudwatch_log_group" {
  description         = "KMS key used to encrypt Kubernetes, VPC Flow, Amazon RDS for PostgreSQL and SSM Patch manager log groups within infrastructure ${var.infrastructurename}"
  enable_key_rotation = true
  tags                = var.tags
  policy              = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "key-default-1",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${local.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "logs.${local.region}.amazonaws.com"
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
                    "kms:EncryptionContext:aws:logs:arn": "arn:aws:logs:${local.region}:${local.account_id}:*"
                }
            }
        }
    ]
}
POLICY
}
