resource "kubernetes_namespace" "scenario_generation" {
  metadata {
    name = var.k8s_namespace
  }
}

resource "aws_iam_role" "scenario_generation_service_account" {
  name        = "${local.instancename}-sa-role"
  description = "IAM role for OpenSearch and Bedrock service account"
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
            "${local.eks_oidc_issuer}:sub" : "system:serviceaccount:${var.k8s_namespace}:${local.opensearch_bedrock_serviceaccount}"
          }
        }
      }
    ]
  })
}

resource "kubernetes_service_account" "scenario_generation" {
  metadata {
    name      = local.opensearch_bedrock_serviceaccount
    namespace = kubernetes_namespace.scenario_generation.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.scenario_generation_service_account.arn
    }
  }
  automount_service_account_token = false
}
