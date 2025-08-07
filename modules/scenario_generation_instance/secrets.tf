data "aws_secretsmanager_secret" "opensearch_secret" {
  count = var.opensearch.enable ? 1 : 0
  name  = var.opensearch.master_user_secret_name
}
data "aws_secretsmanager_secret_version" "opensearch_secret" {
  count     = var.opensearch.enable ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.opensearch_secret[0].id
}

data "aws_secretsmanager_secret" "postgresql_secret" {
  name = var.secretname
}
data "aws_secretsmanager_secret_version" "postgresql_secret" {
  secret_id = data.aws_secretsmanager_secret.postgresql_secret.id
}
