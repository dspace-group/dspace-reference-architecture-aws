data "aws_iam_policy_document" "scenario_generation_opensearch_access" {
  count = var.opensearch.enable ? 1 : 0
  statement {
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.backend_service_account.arn,
        aws_iam_role.ragcore_service_account.arn
      ]
    }

    actions   = ["es:*"]
    resources = ["arn:aws:es:${var.aws_context.region_name}:${var.aws_context.caller_identity_account_id}:domain/${var.opensearch.domain_name}/*"]
  }
}

data "http" "aws_tls_certificate" {
  url = "https://truststore.pki.rds.amazonaws.com/${var.aws_context.region_name}/${var.aws_context.region_name}-bundle.pem"
}
