locals {
  # This service account is automatically created by the add-on.
  aws_cloudwatch_observability_service_account = "cloudwatch-observability-sa"
  aws_cloudwatch_log_group_names = var.cloudwatch_observability_config.enable ? [
    "/aws/containerinsights/${var.addon_context.eks_cluster_id}/application",
    "/aws/containerinsights/${var.addon_context.eks_cluster_id}/dataplane",
    "/aws/containerinsights/${var.addon_context.eks_cluster_id}/host",
    "/aws/containerinsights/${var.addon_context.eks_cluster_id}/performance",
    "/aws/containerinsights/${var.addon_context.eks_cluster_id}/prometheus"
  ] : []
}

data "aws_eks_addon_version" "cloudwatch_observability" {
  count              = var.cloudwatch_observability_config.enable ? 1 : 0
  addon_name         = "amazon-cloudwatch-observability"
  kubernetes_version = var.addon_context.eks_cluster_version
}

resource "aws_eks_addon" "cloudwatch_observability" {
  count                       = var.cloudwatch_observability_config.enable ? 1 : 0
  cluster_name                = var.addon_context.eks_cluster_id
  addon_name                  = "amazon-cloudwatch-observability"
  addon_version               = data.aws_eks_addon_version.cloudwatch_observability[0].version
  service_account_role_arn    = aws_iam_role.cloudwatch_observability_role[0].arn
  preserve                    = false
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  tags                        = var.tags
  configuration_values = templatefile("${path.module}/templates/cloudwatch_observability_values.json", {
    region       = var.addon_context.aws_context.region_name,
    cluster_name = var.addon_context.eks_cluster_id
  })
  depends_on = [aws_cloudwatch_log_group.cloudwatch_log_groups]
}

resource "aws_iam_role" "cloudwatch_observability_role" {
  count       = var.cloudwatch_observability_config.enable ? 1 : 0
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
            "${var.addon_context.eks_oidc_issuer_url}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  force_detach_policies = true

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cloudwatch_observability_policy_attachment" {
  count      = var.cloudwatch_observability_config.enable ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.cloudwatch_observability_role[0].name
}

resource "aws_cloudwatch_log_group" "cloudwatch_log_groups" {
  for_each = {
    for name in local.aws_cloudwatch_log_group_names :
    name => name
  }
  name              = each.value
  retention_in_days = var.cloudwatch_observability_config.retention_period
  log_group_class   = "STANDARD"
  tags              = var.tags
}
