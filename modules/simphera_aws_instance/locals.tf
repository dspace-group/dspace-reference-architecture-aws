locals {
  eks_oidc_issuer          = replace(var.eks_oidc_issuer_url, "https://", "")
  minio_serviceaccount     = "minio-irsa"
  secret_postgres_username = "dbuser" # username is hardcoded because changing the username forces replacement of the db instance
  secrets                  = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)
  instancename             = join("-", [var.infrastructurename, var.name])
  backup_resources         = concat([aws_db_instance.simphera.arn], var.enableKeycloak ? [aws_db_instance.keycloak[0].arn] : [], [aws_s3_bucket.bucket.arn])
  db_simphera_id           = "${local.instancename}-simphera"
  db_keycloak_id           = "${local.instancename}-keycloak"
  backup_vault_name        = "${local.instancename}-backup-vault"
  s3_cors_rules = concat(
    var.simphera_url == null ? [] : [{
      id              = "simphera-access"
      allowed_methods = ["GET", "HEAD"]
      allowed_origins = [var.simphera_url]
      allowed_headers = ["Authorization"]
      expose_headers  = ["Access-Control-Allow-Origin"]
      max_age_seconds = null
    }],
    var.s3_cors_rules
  )
}
