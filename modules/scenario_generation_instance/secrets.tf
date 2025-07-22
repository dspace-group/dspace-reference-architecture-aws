data "aws_secretsmanager_secret" "secrets" {
  name = var.secretname
}

data "aws_secretsmanager_secret_version" "secrets" {
  secret_id = data.aws_secretsmanager_secret.secrets.id
}

# data "aws_secretsmanager_secret" "opensearch_secret" {
#   count = var.opensearch.enable ? 1 : 0
#   name  = var.opensearch.master_user_secret_name
# }
# data "aws_secretsmanager_secret_version" "opensearch_secret" {
#   count     = var.opensearch.enable ? 1 : 0
#   secret_id = data.aws_secretsmanager_secret.opensearch_secret[0].id
# }
