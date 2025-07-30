locals {
  eks_oidc_issuer           = replace(var.eks_oidc_issuer_url, "https://", "")
  opensearch_serviceaccount = "opensearch-irsa"
  bedrock_serviceaccount    = "bedrock-irsa"
  secret_postgres_username  = "dbuser" # username is hardcoded because changing the username forces replacement of the db instance
  secrets                   = jsondecode(data.aws_secretsmanager_secret_version.scenario_generation_secrets.secret_string)
  instancename              = join("-", [var.infrastructurename, var.name])
  backup_resources          = [aws_db_instance.scenario_generation.arn]
  backup_vault_name         = "${local.instancename}-backup-vault"
  db_scenario_generation_id = "${local.instancename}-scenario-generation"
}
