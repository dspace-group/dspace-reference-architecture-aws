resource "kubernetes_namespace" "scenario_generation" {
  metadata {
    name = var.k8s_namespace
  }
}

resource "aws_iam_role" "ragcore_service_account" {
  name        = "${local.instancename}-ragcore-sa-role"
  description = "IAM role for OpenSearch and Bedrock service account for RAG core"
  tags        = var.tags
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
            "${local.eks_oidc_issuer}:sub" : "system:serviceaccount:${var.k8s_namespace}:${local.ragcore_opensearch_bedrock_serviceaccount}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "backend_service_account" {
  name        = "${local.instancename}-backend-sa-role"
  description = "IAM role for OpenSearch and Bedrock service account for backend"
  tags        = var.tags
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
            "${local.eks_oidc_issuer}:sub" : "system:serviceaccount:${var.k8s_namespace}:${local.backend_opensearch_bedrock_serviceaccount}"
          }
        }
      }
    ]
  })
}
resource "kubernetes_service_account" "scenario_generation_ragcore" {
  metadata {
    name      = local.ragcore_opensearch_bedrock_serviceaccount
    namespace = kubernetes_namespace.scenario_generation.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.ragcore_service_account.arn
    }
  }
  automount_service_account_token = false
}

resource "kubernetes_service_account" "scenario_generation_backend" {
  metadata {
    name      = local.backend_opensearch_bedrock_serviceaccount
    namespace = kubernetes_namespace.scenario_generation.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.backend_service_account.arn
    }
  }
  automount_service_account_token = false
}
