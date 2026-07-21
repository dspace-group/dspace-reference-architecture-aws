module "eks" {
  source                                 = "./modules/eks"
  cluster_version                        = var.kubernetesVersion
  cluster_name                           = var.cluster_name
  subnet_ids                             = local.private_subnets
  eks_api_subnet_ids                     = var.eks_api_subnet_ids
  node_groups                            = local.node_pools
  map_accounts                           = var.map_accounts
  map_users                              = var.map_users
  map_roles                              = var.map_roles
  cloudwatch_log_group_kms_key_id        = var.aws_managed_kms ? null : aws_kms_key.kms_key_cloudwatch_log_group[0].arn
  cloudwatch_log_group_retention_in_days = var.cloudwatch_retention
  cluster_enabled_log_types              = ["audit", "api", "authenticator", "controllerManager", "scheduler"]
  aws_context                            = local.aws_context
  tags                                   = var.eks_tags
  aws_managed_kms                        = var.aws_managed_kms
  vpc_cni_addon_configuration            = var.vpc_cni_addon_configuration
  existing_cluster_role_name             = var.existing_cluster_role_name
  oidc_thumbprint                        = var.eks_oidc_thumbrint

  depends_on = [module.vpc]
}

resource "kubernetes_namespace" "monitoring_namespace" {
  metadata {
    name = var.simphera_monitoring_namespace
  }
  depends_on = [module.k8s_eks_addons]
}
