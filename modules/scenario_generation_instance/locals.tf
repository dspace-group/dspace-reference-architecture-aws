locals {
  eks_oidc_issuer                           = replace(var.eks_oidc_issuer_url, "https://", "")
  ragcore_opensearch_bedrock_serviceaccount = "ragcore-opensearch-bedrock-irsa"
  backend_opensearch_bedrock_serviceaccount = "backend-opensearch-bedrock-irsa"
  opensearch_serviceaccount                 = "opensearch-irsa"
  secret_postgres_username                  = "dbuser" # username is hardcoded because changing the username forces replacement of the db instance
  postgresql_secret                         = jsondecode(data.aws_secretsmanager_secret_version.postgresql_secret.secret_string)
  instancename                              = join("-", [var.infrastructurename, var.name])
  backup_resources                          = [aws_db_instance.scenario_generation.arn]
  backup_vault_name                         = "${local.instancename}-backup-vault"
  db_scenario_generation_id                 = "${local.instancename}-scenario-generation"
}
