locals {
  aws_cloudwatch_observability_addon_name = "amazon-cloudwatch-observability"
  aws_cloudwatch_observability_namespace  = "kube-system"
  # This service account is automatically created by the add-on.
  aws_cloudwatch_observability_service_account = "cloudwatch_observability-sa"
}

data "aws_eks_addon_version" "cloudwatch_observability" {
  count              = var.cluster_autoscaler_config.enable ? 1 : 0
  addon_name         = local.aws_cloudwatch_observability_addon_name
  kubernetes_version = var.addon_context.eks_cluster_version
}

resource "aws_eks_addon" "cloudwatch_observability" {
  count                       = var.cluster_autoscaler_config.enable ? 1 : 0
  cluster_name                = var.addon_context.eks_cluster_id
  addon_name                  = "amazon-cloudwatch-observability"
  addon_version               = data.aws_eks_addon_version.cloudwatch_observability[0].version
  service_account_role_arn    = aws_iam_role.cloudwatch_observability_role[0].arn
  preserve                    = false
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  tags                        = var.tags
  configuration_values        = file("${path.module}/templates/cloudwatch_observability_values.yaml")
}

resource "aws_iam_role" "cloudwatch_observability_role" {
  count       = var.cluster_autoscaler_config.enable ? 1 : 0
  name        = format("%s-%s-%s", var.addon_context.eks_cluster_id, trimsuffix(local.aws_cloudwatch_observability_service_account, "-sa"), "irsa")
  description = "AWS IAM Role for the Kubernetes service account ${local.aws_cloudwatch_observability_service_account}."

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:${var.addon_context.aws_context.partition_id}:iam::${var.addon_context.aws_context.caller_identity_account_id}:oidc-provider/${var.addon_context.eks_oidc_issuer_url}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringLike" : {
            "${var.addon_context.eks_oidc_issuer_url}:sub" : "system:serviceaccount:${local.aws_cloudwatch_observability_namespace}:${local.aws_cloudwatch_observability_service_account}",
            "${var.addon_context.eks_oidc_issuer_url}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  force_detach_policies = true

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy_attachment" {
  count      = var.cluster_autoscaler_config.enable ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.cloudwatch_observability_role[0].name
}
