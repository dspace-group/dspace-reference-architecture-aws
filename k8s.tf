module "eks" {
  source                                 = "./modules/eks"
  cluster_version                        = var.eks.version
  cluster_name                           = local.eks_cluster_name
  subnet_ids                             = local.private_subnets_ids
  eks_api_subnet_ids                     = var.eks.api_subnet_ids
  node_groups                            = var.eks.node_groups
  map_principals                         = var.eks.map_principals
  cloudwatch_log_group_kms_key_id        = var.aws_managed_kms ? null : aws_kms_key.cloudwatch_log_group[0].arn
  cloudwatch_log_group_retention_in_days = coalesce(var.eks.cloudwatch_log_group_retention, var.cloudwatch_retention)
  aws_context                            = local.aws_context
  tags                                   = var.tags
  aws_managed_kms                        = var.aws_managed_kms
  vpc_cni_addon_configuration            = var.vpc_cni_addon_configuration

  depends_on = [module.vpc]
}
