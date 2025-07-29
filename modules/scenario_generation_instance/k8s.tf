resource "kubernetes_namespace" "scenario_generation" {
  metadata {
    name = var.k8s_namespace
  }
}
