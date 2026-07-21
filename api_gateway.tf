module "ivs_api_gateway" {
  source            = "./modules/api_gateway"
  count             = var.enable_api_gateway ? 1 : 0
  deployment_name   = "ivs-${var.deployment_name}"
  vpc_id            = local.vpc_id
  public_subnet_ids = local.public_subnets
  domain_name       = "ivs.${var.hosted_zone}"
  hosted_zone_name  = var.hosted_zone
  cluster_name      = module.eks.eks_cluster_id
  external_oidc     = var.external_oidc
  providers = {
    aws = aws.tagged_ivs
  }
}
