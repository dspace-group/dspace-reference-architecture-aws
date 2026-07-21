variable "helm_config" {
  type        = any
  description = "Cert Manager Helm chart configuration"
  default     = {}
}

variable "infrastructurename" {
  type = string
}

variable "oidc_arn" {
  type = string
}

variable "tags" {
  type        = map(string)
  description = "The tags to be added to all resources."
  default     = {}
}
