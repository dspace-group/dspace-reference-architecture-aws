module "certmanager" {
  source = "./modules/k8s_eks_addons/cert-manager"
  count  = var.enable_certmanager ? 1 : 0
  helm_config = {
    namespace          = "cert-manager",
    install_default_ca = false
    create_namespace   = true,
    version            = "v1.9.1",
  }
  infrastructurename = var.infrastructurename
  oidc_arn           = module.eks.eks_oidc_provider_arn
  tags               = var.tags
}
