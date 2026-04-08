resource "kubernetes_namespace_v1" "traefik" {
  count = var.traefik_config.enable ? 1 : 0

  metadata {
    name = "traefik-ingress"
  }
}

resource "helm_release" "traefik" {
  count = var.traefik_config.enable ? 1 : 0

  namespace         = kubernetes_namespace_v1.traefik[0].metadata[0].name
  name              = "traefik-ingress"
  chart             = "traefik"
  repository        = var.traefik_config.helm_repository
  version           = var.traefik_config.helm_version
  description       = "The Traefik HelmChart Ingress Controller deployment configuration"
  dependency_update = true
  values = [
    templatefile("${path.module}/templates/traefik_values.yaml", {
      tags                   = local.string_tags
      public_subnets         = join(", ", var.ingress_nginx_config.subnets_ids)
      ingress_nginx_enabled  = var.ingress_nginx_config.enable
      protocol               = var.aws_load_balancer_controller_config.enable ? "ssl" : "tcp"
      aws_load_balancer_type = var.aws_load_balancer_controller_config.enable ? "external" : "nlb"
      aws_load_target-type   = var.aws_load_balancer_controller_config.enable ? "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip" : ""
    }),
    var.traefik_config.chart_values
  ]
  timeout    = 1200
  depends_on = [helm_release.aws_load_balancer_controller]
}
