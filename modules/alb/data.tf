data "aws_route53_zone" "hosted_zone" {
  name         = var.hosted_zone_name
  private_zone = false
}

data "aws_secretsmanager_secret_version" "oidc_secrets" {
  secret_id = var.external_oidc.oidc_secret_name
}
