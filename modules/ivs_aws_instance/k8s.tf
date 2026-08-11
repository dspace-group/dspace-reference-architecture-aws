resource "kubernetes_namespace_v1" "k8s_namespace" {
  metadata {
    name = var.k8s_namespace
  }
}
