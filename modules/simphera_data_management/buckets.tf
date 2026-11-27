resource "aws_s3_bucket" "data_management" {
  for_each = local.buckets
  bucket   = each.value.name
  # TODO: immutability?
  tags = var.tags
}

resource "aws_s3_bucket_logging" "data_management" {
  for_each      = local.logged_buckets
  bucket        = aws_s3_bucket.data_management[each.key].id
  target_bucket = var.logging_bucket
  target_prefix = "logs/bucket/${aws_s3_bucket.data_management[each.key].id}/"
}

resource "aws_s3_bucket_versioning" "data_management" {
  for_each = local.versioned_buckets
  bucket   = aws_s3_bucket.data_management[each.key].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role_policy" "eks_node_s3_access" {
  for_each = var.node_role_names
  role     = each.value
  name     = "s3-access-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:GetEncryptionConfiguration"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = ["s3:ListBucket"]
        Effect   = "Allow"
        Resource = local.bucket_arns
      },
      {
        Action   = ["s3:Get*", "s3:List*", "s3-object-lambda:Get*", "s3-object-lambda:List*"]
        Effect   = "Allow"
        Resource = local.bucket_object_arns
      },
      {
        Action   = ["s3:DeleteObject", "s3:PutObject"]
        Effect   = "Allow"
        Resource = local.bucket_object_arns
      }
    ]
  })
}

resource "aws_iam_role" "s3_access_sa" {
  name = "${var.identifier}-role"
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
            "${var.eks_oidc_issuer}:sub" : "system:serviceaccount:${kubernetes_namespace_v1.data_management.metadata[0].name}:${local.s3_access_sa_name}"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "s3_access_sa" {
  role = aws_iam_role.s3_access_sa.id
  name = "${var.identifier}-s3-access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:GetEncryptionConfiguration"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = ["s3:ListBucket"]
        Effect   = "Allow"
        Resource = local.bucket_arns
      },
      {
        Action   = ["s3:Get*", "s3:List*", "s3-object-lambda:Get*", "s3-object-lambda:List*"]
        Effect   = "Allow"
        Resource = local.bucket_object_arns
      },
      {
        Action   = ["s3:PutObject"]
        Effect   = "Allow"
        Resource = local.bucket_object_arns
      }
    ]
  })
}

resource "kubernetes_service_account_v1" "s3_access_sa" {
  metadata {
    name      = local.s3_access_sa_name
    namespace = kubernetes_namespace_v1.data_management.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.s3_access_sa.arn
    }
  }
  automount_service_account_token = false
}
