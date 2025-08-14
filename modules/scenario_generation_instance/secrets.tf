data "aws_secretsmanager_secret" "postgresql_secret" {
  name = var.secretname
}

data "aws_secretsmanager_secret_version" "postgresql_secret" {
  secret_id = data.aws_secretsmanager_secret.postgresql_secret.id
}
