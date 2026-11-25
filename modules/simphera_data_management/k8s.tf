resource "kubernetes_namespace_v1" "data_management" {
  metadata {
    name = var.k8s_namespace
  }
}
