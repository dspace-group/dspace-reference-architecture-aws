module "eks" {
  source                                 = "./modules/eks"
  cluster_version                        = var.kubernetesVersion
  cluster_name                           = var.infrastructurename
  subnet_ids                             = local.private_subnets
  eks_api_subnet_ids                     = var.eks_api_subnet_ids
  node_groups                            = local.node_pools
  map_accounts                           = var.map_accounts
  map_users                              = var.map_users
  map_roles                              = var.map_roles
  cloudwatch_log_group_kms_key_id        = aws_kms_key.kms_key_cloudwatch_log_group.arn
  cloudwatch_log_group_retention_in_days = var.cloudwatch_retention
  aws_context                            = local.aws_context
  tags                                   = var.tags
  use_aws_managed_kms                    = var.use_aws_managed_kms

  depends_on = [module.vpc]
}

resource "kubernetes_namespace" "monitoring_namespace" {
  metadata {
    name = var.simphera_monitoring_namespace
  }
  depends_on = [module.k8s_eks_addons]
}
