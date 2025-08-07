resource "aws_opensearch_domain" "scenario_generation_opensearch" {
  count          = var.opensearch.enable ? 1 : 0
  domain_name    = var.opensearch.domain_name
  engine_version = var.opensearch.engine_version
  advanced_security_options {
    enabled                        = false
    internal_user_database_enabled = true
    # master_user_options {
    #   master_user_arn = aws_iam_role.opensearch_service_account.arn
    # }
    master_user_options {
      master_user_name     = local.opensearch_secret["master_user"]
      master_user_password = local.opensearch_secret["master_password"]
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
  access_policies = data.aws_iam_policy_document.scenario_generation_opensearch_access[0].json
  tags            = var.tags
}

# resource "aws_iam_policy" "opensearch_access_policy" {
#   name        = "${local.instancename}-opensearch-access-policy"
#   description = "Policy for OpenSearch access"
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Effect   = "Allow",
#       Action   = ["es:*"],
#       Resource = ["arn:aws:es:${var.aws_context.region_name}:${var.aws_context.caller_identity_account_id}:domain/${var.opensearch.domain_name}/*"]
#     }]
#   })
# }
# resource "aws_iam_role_policy_attachment" "ragcore_policy_attachment" {
#   role       = aws_iam_role.ragcore_service_account.name
#   policy_arn = aws_iam_policy.opensearch_access_policy.arn
# }

# resource "aws_iam_role_policy_attachment" "backend_policy_attachment" {
#   role       = aws_iam_role.backend_service_account.name
#   policy_arn = aws_iam_policy.opensearch_access_policy.arn
# }
