module "data_management" {
  source      = "./modules/simphera_data_management"
  count       = var.data_management.enable ? 1 : 0
  identifier  = "${var.infrastructure_name}-dm"
  aws_context = local.aws_context
  buckets     = var.data_management.buckets
  opensearch = merge(var.data_management.opensearch, {
    subnet_ids         = local.private_subnets_ids
    security_group_ids = [module.eks.cluster_primary_security_group_id]
    }
  )
  logging_bucket        = aws_s3_bucket.logs_bucket.bucket
  k8s_namespace         = var.data_management.k8s_namespace
  eks_oidc_issuer       = replace(module.eks.eks_oidc_issuer_url, "https://", "")
  eks_oidc_provider_arn = module.eks.eks_oidc_provider_arn
  node_role_names       = local.data_management_node_role_names
  tags                  = var.tags
}
