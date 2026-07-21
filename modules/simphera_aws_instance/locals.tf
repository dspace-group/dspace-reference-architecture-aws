locals {
  eks_oidc_issuer          = replace(var.eks_oidc_issuer_url, "https://", "")
  minio_serviceaccount     = "minio-irsa"
  secret_postgres_username = "dbuser" # username is hardcoded because changing the username forces replacement of the db instance
  secrets                  = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)
  instancename             = join("-", [var.infrastructurename, var.name])
  backup_resources         = concat([aws_db_instance.simphera.arn], var.enableKeycloak ? [aws_db_instance.keycloak[0].arn] : [], [aws_s3_bucket.bucket.arn], [for bucket in aws_s3_bucket.extra : bucket.arn])
  db_simphera_id           = var.psql_simphera_name == null ? "${local.instancename}-simphera" : var.psql_simphera_name
  db_keycloak_id           = "${local.instancename}-keycloak"
  backup_vault_name        = var.backup_vault_name == null ? "${local.instancename}-backup-vault" : var.backup_vault_name
}
