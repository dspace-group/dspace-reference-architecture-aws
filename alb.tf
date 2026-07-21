module "main_alb" {
  source            = "./modules/alb"
  count             = var.enable_alb ? 1 : 0
  deployment_name   = "ivs-${var.deployment_name}"
  vpc_id            = local.vpc_id
  internal          = false
  public_subnet_ids = local.public_subnets
  domain_names      = toset(["api.ivs.${var.hosted_zone}", "ivs.${var.hosted_zone}"])
  domain_name       = "ivs.${var.hosted_zone}"
  hosted_zone_name  = var.hosted_zone
  wildcard_cert_arn = var.cert_arn
  external_oidc     = var.external_oidc
  providers = {
    aws = aws.tagged_ivs
  }
}
