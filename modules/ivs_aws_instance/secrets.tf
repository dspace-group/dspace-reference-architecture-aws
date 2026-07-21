data "aws_secretsmanager_secret" "opensearch_secret" {
  count = var.opensearch.enable ? 1 : 0
  name  = var.opensearch.master_user_secret_name
}

data "aws_secretsmanager_secret_version" "opensearch_secret" {
  count     = var.opensearch.enable ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.opensearch_secret[0].id
}

data "aws_secretsmanager_secret" "database_secrets" {
  count = var.enableIVSAuthentication ? 1 : 0
  name  = var.database_secretname
}

data "aws_secretsmanager_secret_version" "database_secrets" {
  count     = var.enableIVSAuthentication ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.database_secrets[0].id
}
