module "scenario_generation_instance" {
  source                               = "./modules/scenario_generation_instance"
  for_each                             = var.scenarioGenerationInstances
  region                               = local.region
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
  cloudwatch_retention                 = var.cloudwatch_retention
  enable_deletion_protection           = each.value.enable_deletion_protection
  postgresql_security_group_id         = module.security_group.security_group_id
  kms_key_cloudwatch                   = aws_kms_key.kms_key_cloudwatch_log_group.arn
  private_subnets                      = local.private_subnets

  depends_on = [module.eks, kubernetes_storage_class_v1.efs]
}
