locals {
  database_identifier = var.instance_identifier
  secrets             = jsondecode(data.aws_secretsmanager_secret_version.database.secret_string)
}
