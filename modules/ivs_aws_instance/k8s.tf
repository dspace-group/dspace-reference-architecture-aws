resource "kubernetes_namespace" "k8s_namespace" {
  metadata {
    name        = var.k8s_namespace
    annotations = var.enable_service_mesh ? { "linkerd.io/inject" = "enabled" } : {}
  }
}
