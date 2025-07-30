data "aws_secretsmanager_secret" "scenario_generation_secrets" {
  name = var.secretname
}

data "aws_secretsmanager_secret_version" "scenario_generation_secrets" {
  secret_id = data.aws_secretsmanager_secret.scenario_generation_secrets.id
}
