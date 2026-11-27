locals {
  aws_s3_csi_addon_name = "aws-mountpoint-s3-csi-driver"
}

data "aws_eks_addon_version" "aws-mountpoint-s3-csi-driver" {
  count              = var.s3_csi_config.enable ? 1 : 0
  addon_name         = local.aws_s3_csi_addon_name
  kubernetes_version = var.addon_context.eks_cluster_version
}

resource "aws_eks_addon" "aws-mountpoint-s3-csi-driver" {
  count                       = var.s3_csi_config.enable ? 1 : 0
  cluster_name                = var.addon_context.eks_cluster_id
  addon_name                  = local.aws_s3_csi_addon_name
  addon_version               = data.aws_eks_addon_version.aws-mountpoint-s3-csi-driver[0].version
  preserve                    = true
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  configuration_values        = var.s3_csi_config.configuration_values
  tags                        = var.tags
}
