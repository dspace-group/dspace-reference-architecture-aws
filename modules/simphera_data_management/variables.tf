variable "identifier" {
  type = string
}

variable "buckets" {
  type = list(object({
    create     = bool
    name       = string
    versioning = bool
    logging    = bool
  }))
}

variable "opensearch" {
  type = object({
    enable                  = bool
    subnet_ids              = list(string)
    domain_name             = string
    engine_version          = string
    instance_type           = string
    instance_count          = number
    volume_size             = number
    master_user_secret_name = string
    security_group_ids      = list(string)
  })
  description = "Input variables for configuring an AWS's OpenSearch domain"
}

variable "logging_bucket" {
  type = string
}

variable "aws_context" {
  type = object({
    caller_identity_account_id = string
    region_name                = string
  })
  description = "Object containing data about AWS, e.g. aws_caller_identity, aws_partition etc."
}

variable "k8s_namespace" {
  type = string
}

variable "eks_oidc_provider_arn" {
  type        = string
  description = "The ARN of the OIDC Provider"
}

variable "eks_oidc_issuer" {
  type        = string
  description = "The URL on the EKS cluster OIDC Issuer"
}

variable "node_role_names" {
  type        = map(string)
  description = "Map of EKS nodes role names"
}

variable "tags" {
  type = map(string)
}
