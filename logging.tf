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

# VPC logging
## [EC2.6] VPC flow logging should be enabled in all VPCs
## https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards-fsbp-controls.html#fsbp-ec2-6
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count             = local.create_vpc ? 1 : 0
  name              = "/aws/vpc/${var.infrastructure_name}"
  retention_in_days = coalesce(var.vpc.flow_logs_retention, var.cloudwatch_retention)
  kms_key_id        = local.kms_cloudwatch_key_arn
  tags              = var.tags
}

resource "aws_flow_log" "vpc" {
  count           = local.create_vpc ? 1 : 0
  iam_role_arn    = aws_iam_role.vpc_flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  traffic_type    = "ALL"
  vpc_id          = local.vpc_id
  tags            = var.tags
}

resource "aws_iam_role" "vpc_flow_logs" {
  count              = local.create_vpc ? 1 : 0
  name               = "${var.infrastructure_name}-flowlogs-role"
  description        = "AWS IAM service role for VPC flow logs."
  assume_role_policy = <<-EOF
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
            "Service": "vpc-flow-logs.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
    }
    EOF
  tags               = var.tags
}

resource "aws_iam_policy" "vpc_flow_logs" {
  count  = local.create_vpc ? 1 : 0
  name   = "${var.infrastructure_name}-flowlogs-policy"
  policy = <<-EOF
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Action": [
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams"
        ],
        "Effect": "Allow",
        "Resource": "*"
        }
    ]
    }
    EOF
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "vpc_flow_logs" {
  count      = local.create_vpc ? 1 : 0
  role       = aws_iam_role.vpc_flow_logs[0].id
  policy_arn = aws_iam_policy.vpc_flow_logs[0].arn
}
