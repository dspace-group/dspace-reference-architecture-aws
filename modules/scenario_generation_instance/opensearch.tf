resource "aws_iam_role" "opensearch_iam_role" {
  count       = var.opensearch.enable ? 1 : 0
  name        = "${local.instancename}-opensearch-role"
  description = "IAM role for the OpenSearch service account"
  tags        = var.tags
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : var.eks_oidc_provider_arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${local.eks_oidc_issuer}:sub" : "system:serviceaccount:${var.k8s_namespace}:${local.opensearch_serviceaccount}"
          }
        }
      }
    ]
  })
}

resource "kubernetes_service_account" "opensearch_service_account" {
  count = var.opensearch.enable ? 1 : 0
  metadata {
    name      = local.opensearch_serviceaccount
    namespace = kubernetes_namespace.k8s_namespace.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.opensearch_iam_role[0].arn
    }
  }
  automount_service_account_token = false
}

resource "aws_opensearch_domain" "opensearch" {
  count          = var.opensearch.enable ? 1 : 0
  domain_name    = var.opensearch.domain_name
  engine_version = var.opensearch.engine_version
  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = false
    master_user_options {
      master_user_arn = aws_iam_role.opensearch_iam_role[0].arn
    }
  }
  node_to_node_encryption {
    enabled = true
  }
  encrypt_at_rest {
    enabled = true
  }
  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-0-2019-07"
  }
  cluster_config {
    instance_count         = var.opensearch.instance_count
    instance_type          = var.opensearch.instance_type
    zone_awareness_enabled = var.opensearch.instance_count > 1 ? true : false
    dynamic "zone_awareness_config" {
      for_each = var.opensearch.instance_count > 1 ? [1] : []
      content {
        availability_zone_count = var.opensearch.instance_count < 3 ? var.opensearch.instance_count : 3
      }
    }
  }
  ebs_options {
    ebs_enabled = true
    volume_type = "gp3"
    volume_size = var.opensearch.volume_size
    iops        = 3000
    throughput  = 125
  }
  vpc_options {
    subnet_ids         = slice(var.opensearch.subnet_ids, 0, var.opensearch.instance_count < 3 ? var.opensearch.instance_count : 3)
    security_group_ids = var.opensearch.security_group_ids
  }
  access_policies = data.aws_iam_policy_document.opensearch_access[0].json
  tags            = var.tags
}
