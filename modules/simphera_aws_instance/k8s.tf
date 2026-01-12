resource "kubernetes_namespace" "k8s_namespace" {
  metadata {

    name = var.k8s_namespace
  }
}

resource "kubernetes_service_account" "minio" {
  metadata {
    name      = local.minio_serviceaccount
    namespace = kubernetes_namespace.k8s_namespace.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.minio_irsa.arn
    }
  }
  automount_service_account_token = false
}

resource "kubernetes_service_account" "simphera" {
  metadata {
    name      = "simphera-irsa"
    namespace = kubernetes_namespace.k8s_namespace.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.simphera_irsa.arn
    }
  }
  automount_service_account_token = false
}

resource "kubernetes_service_account" "executoragentlinux" {
  metadata {
    name      = "executoragentlinux-irsa"
    namespace = kubernetes_namespace.k8s_namespace.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.executoragentlinux_irsa.arn
    }
  }
  automount_service_account_token = false
}
