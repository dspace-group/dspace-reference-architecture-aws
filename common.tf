module "simphera_common" {
  source              = "./modules/simphera_common"
  instance_identifier = var.infrastructure_name
  database = {
    db_name                    = var.database.db_name
    postgresqlApplyImmediately = var.database.postgresqlApplyImmediately
    postgresqlStorage          = var.database.postgresqlStorage
    postgresqlMaxStorage       = var.database.postgresqlMaxStorage
    postgresqlVersion          = var.database.postgresqlVersion
    db_instance_type           = var.database.db_instance_type
    enable_deletion_protection = var.database.enable_deletion_protection
    multi_az                   = var.database.multi_az
    cloudwatch_retention       = coalesce(var.database.cloudwatch_retention, var.cloudwatch_retention)
    secret_name                = var.database.secret_name
    private_subnets_ids        = local.private_subnets_ids
  }
  vpc_id                 = local.vpc_id
  vpc_cidr               = local.vpc_cidr
  kms_cloudwatch_key_arn = local.kms_cloudwatch_key_arn
  tags                   = var.tags
}
