data "aws_secretsmanager_secret" "database" {
  name = var.database.secret_name
}

data "aws_secretsmanager_secret_version" "database" {
  secret_id = data.aws_secretsmanager_secret.database.id
}
