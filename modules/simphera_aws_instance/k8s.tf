resource "kubernetes_namespace_v1" "k8s_namespace" {
  metadata {

    name = var.k8s_namespace
  }
}

resource "kubernetes_service_account_v1" "minio" {
  count = var.enable_minio ? 1 : 0
  metadata {
    name      = local.minio_serviceaccount
    namespace = kubernetes_namespace_v1.k8s_namespace.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.minio_irsa[0].arn
    }
  }
  automount_service_account_token = false
}

resource "kubernetes_service_account_v1" "simphera" {
  count = var.enable_minio ? 0 : 1
  metadata {
    name      = "simphera-irsa"
    namespace = kubernetes_namespace_v1.k8s_namespace.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.simphera_irsa[0].arn
    }
  }
}

resource "kubernetes_service_account_v1" "executoragentlinux" {
  count = var.enable_minio ? 0 : 1
  metadata {
    name      = "executoragentlinux-irsa"
    namespace = kubernetes_namespace_v1.k8s_namespace.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.executoragentlinux_irsa[0].arn
    }
  }
}

resource "kubernetes_service_account_v1" "executoragentlinuxsubjob" {
  count = var.enable_minio ? 0 : 1
  metadata {
    name      = "executoragentlinuxsubjob-irsa"
    namespace = kubernetes_namespace_v1.k8s_namespace.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.executoragentlinuxsubjob_irsa[0].arn
    }
  }
}
