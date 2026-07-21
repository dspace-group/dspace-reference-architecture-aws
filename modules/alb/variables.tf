variable "deployment_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "internal" {
  type = bool
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "domain_names" {
  type = set(string)
}
variable "domain_name" {
  type = string
}

variable "hosted_zone_name" {
  type = string
}

variable "wildcard_cert_arn" {
  type = string
}

variable "external_oidc" {
  type = object({
    authorization_endpoint = string
    client_id              = string
    issuer                 = string
    token_endpoint         = string
    user_info_endpoint     = string
    oidc_secret_name       = string
  })
  description = "oidc_secret_name has to contain authentication_openid_client_secret"

}
