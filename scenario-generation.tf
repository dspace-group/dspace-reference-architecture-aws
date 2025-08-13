module "scenario_generation_instance" {
  source                               = "./modules/scenario_generation_instance"
  for_each                             = var.scenarioGenerationInstances.instances
  infrastructurename                   = local.infrastructurename
  tags                                 = var.tags
  eks_oidc_issuer_url                  = module.eks.eks_oidc_issuer_url
  eks_oidc_provider_arn                = module.eks.eks_oidc_provider_arn
  name                                 = each.value.name
  postgresqlApplyImmediately           = each.value.postgresqlApplyImmediately
  postgresqlVersion                    = each.value.postgresqlVersion
  postgresqlStorage                    = each.value.postgresqlStorage
  postgresqlMaxStorage                 = each.value.postgresqlMaxStorage
  db_instance_type_scenario_generation = each.value.db_instance_type_scenario_generation
  k8s_namespace                        = each.value.k8s_namespace
  secretname                           = each.value.secretname
  enable_backup_service                = each.value.enable_backup_service
  backup_retention                     = each.value.backup_retention
  cloudwatch_retention                 = var.cloudwatch_retention
  enable_deletion_protection           = each.value.enable_deletion_protection
  postgresql_security_group_id         = module.security_group.security_group_id
  kms_key_cloudwatch                   = aws_kms_key.kms_key_cloudwatch_log_group.arn
  private_subnets                      = local.private_subnets
  aws_context                          = local.aws_context
  bedrock_region                       = each.value.bedrock_region
  opensearch = merge(each.value.opensearch, {
    domain_name        = "${var.infrastructurename}-${each.key}"
    subnet_ids         = local.private_subnets
    security_group_ids = [module.eks.cluster_primary_security_group_id]
    }
  )

  depends_on = [module.eks]
}
