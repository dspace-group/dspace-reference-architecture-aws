data "aws_secretsmanager_secret" "opensearch_secret" {
  count = var.opensearch.enable ? 1 : 0
  name  = var.opensearch.master_user_secret_name
}

data "aws_secretsmanager_secret_version" "opensearch_secret" {
  count     = var.opensearch.enable ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.opensearch_secret[0].id
}

data "aws_iam_policy_document" "opensearch_access" {
  count = var.opensearch.enable ? 1 : 0
  statement {
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["es:*"]
    resources = ["arn:aws:es:${var.aws_context.region_name}:${var.aws_context.caller_identity_account_id}:domain/${var.opensearch.domain_name}/*"]
  }
}
