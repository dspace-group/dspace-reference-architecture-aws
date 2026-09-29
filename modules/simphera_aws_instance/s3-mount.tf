resource "kubernetes_persistent_volume_v1" "s3_pv" {
  count = var.enable_s3_mount ? 1 : 0
  metadata {
    name = "${aws_s3_bucket.bucket.bucket}-s3-pv"
  }
  spec {
    capacity = {
      # Ignored by the S3 CSI driver, but required by the Kubernetes API.
      storage = "1Gi"
    }
    volume_mode                      = "Filesystem"
    access_modes                     = ["ReadWriteMany"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = ""
    claim_ref {
      name      = "${aws_s3_bucket.bucket.bucket}-s3-pvc"
      namespace = kubernetes_namespace_v1.k8s_namespace.metadata[0].name
    }
    persistent_volume_source {
      csi {
        driver        = "s3.csi.aws.com"
        volume_handle = "${aws_s3_bucket.bucket.bucket}-s3-volume"
        volume_attributes = {
          bucketName           = aws_s3_bucket.bucket.bucket
          authenticationSource = "pod"
        }
      }
    }
  }
}

# PVC statically bound to the S3-backed PV above, for use as a SIMPHERA PersistentVolume storage.
resource "kubernetes_persistent_volume_claim_v1" "s3_pvc" {
  count = var.enable_s3_mount ? 1 : 0
  metadata {
    name      = "${aws_s3_bucket.bucket.bucket}-s3-pvc"
    namespace = kubernetes_namespace_v1.k8s_namespace.metadata[0].name
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = ""
    volume_name        = kubernetes_persistent_volume_v1.s3_pv[0].metadata[0].name
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}
