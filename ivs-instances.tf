module "ivs_instance" {
  source                               = "./modules/ivs_aws_instance"
  for_each                             = var.ivsInstances
  aws_context                          = local.aws_context
  backup_retention                     = each.value.backup_retention
  backup_schedule                      = each.value.backup_schedule
  backup_service_enable                = each.value.backup_service_enable
  cloudwatch_retention                 = var.cloudwatch_retention
  data_bucket                          = each.value.data_bucket
  db_instance_type_ivs                 = each.value.db_instance_type_ivs_authentication
  eks_cluster_id                       = var.infrastructurename
  eks_oidc_issuer                      = replace(module.eks.eks_oidc_issuer_url, "https://", "")
  eks_oidc_provider_arn                = module.eks.eks_oidc_provider_arn
  enable_deletion_protection           = each.value.enable_deletion_protection
  enableIVSAuthentication              = each.value.enable_ivs_authentication
  goofys_user_agent_sdk_and_go_version = each.value.goofys_user_agent_sdk_and_go_version
  instancename                         = each.key
  ivs_release_name                     = each.value.ivs_release_name
  k8s_namespace                        = each.value.k8s_namespace
  kms_key_cloudwatch                   = aws_kms_key.kms_key_cloudwatch_log_group.arn
  log_bucket                           = aws_s3_bucket.bucket_logs.id
  nodeRoleNames                        = local.ivs_node_groups_roles
  opensearch = merge(each.value.opensearch, {
    domain_name        = "${var.infrastructurename}-${each.key}"
    subnet_ids         = local.private_subnets
    security_group_ids = [module.eks.cluster_primary_security_group_id]
    }
  )
  postgresql_security_group_id = module.security_group.security_group_id
  postgresqlApplyImmediately   = each.value.postgresqlApplyImmediately
  postgresqlVersion            = each.value.postgresqlVersion
  private_subnets              = local.private_subnets
  raw_data_bucket              = each.value.raw_data_bucket
  region                       = local.region
  tags                         = var.tags
  depends_on                   = [module.k8s_eks_addons]
}
