locals {
  oidc_secrets = jsondecode(
    data.aws_secretsmanager_secret_version.oidc_secrets.secret_string
  )
}
