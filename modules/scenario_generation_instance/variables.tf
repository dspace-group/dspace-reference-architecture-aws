variable "infrastructurename" {
  type        = string
  description = "The name of the infrastructure. e.g. scenario-generation-infra"
}

variable "postgresql_security_group_id" {
  type        = string
  description = "The ID of the security group"
}

variable "tags" {
  type        = map(any)
  description = "The tags to be added to all resources."
  default     = {}
}

variable "name" {
  type        = string
  description = "The name of the Scenario Generation instance. e.g. production"
}

variable "postgresqlApplyImmediately" {
  type        = bool
  description = "Apply PostgreSQL changes immediately (true) or during next maintenance window (false)"
  default     = false
}

variable "postgresqlVersion" {
  type        = string
  description = "PostgreSQL Server version to deploy"
  default     = "16"
}

variable "postgresqlStorage" {
  type        = number
  description = "PostgreSQL Storage in GiB for Scenario Generation."
  default     = 20
  validation {
    condition     = 20 <= var.postgresqlStorage && var.postgresqlStorage <= 65536
    error_message = "The variable postgresqlStorage must be between 20 and 65536 GiB."
  }
}

variable "postgresqlMaxStorage" {
  type        = number
  description = "The upper limit to which Amazon RDS can automatically scale the storage of the Scenario Generation database. Must be greater than or equal to postgresqlStorage or 0 to disable Storage Autoscaling."
  default     = 20
  validation {
    condition     = 20 <= var.postgresqlMaxStorage && var.postgresqlMaxStorage <= 65536
    error_message = "The variable postgresqlMaxStorage must be between 20 and 65536 GiB."
  }
}

variable "db_instance_type_scenario_generation" {
  type        = string
  description = "PostgreSQL database instance type for Scenario Generation data"
  default     = "db.t4g.large"
}

variable "k8s_namespace" {
  type        = string
  description = "Kubernetes namespace of the Scenario Generation instance"
  default     = "scenario-generation"
}

variable "enable_deletion_protection" {
  type        = bool
  description = "Enable deletion protection for databases and content of s3 buckets."
  default     = true
}

variable "secretname" {
  description = "Secrets manager secret"
  type        = string
}

variable "eks_oidc_issuer_url" {
  type        = string
  description = "The URL on the EKS cluster OIDC Issuer"
}

variable "eks_oidc_provider_arn" {
  type        = string
  description = "The ARN of the OIDC Provider if `enable_irsa = true`."
}

variable "enable_backup_service" {
  default = false
  type    = bool
}

variable "backup_retention" {
  default     = 7
  type        = number
  description = "The retention period for continuous backups can be between 1 and 35 days."
}

variable "kms_key_cloudwatch" {
  type        = string
  description = "ARN of KMS encryption key used to encrypt CloudWatch log groups."
  default     = ""
}

variable "private_subnets" {
  type        = list(any)
  description = "List of CIDRs for the private subnets."
  default     = ["10.1.0.0/22", "10.1.4.0/22", "10.1.8.0/22"]
}

variable "cloudwatch_retention" {
  default     = 7
  description = "Cloudwatch retention period for the PostgreSQL logs."
  type        = number
}

variable "aws_context" {
  type = object({
    caller_identity_account_id = string
    region_name                = string
  })
  description = "Object containing data about AWS, e.g. aws_caller_identity, aws_partition etc."
}

variable "opensearch" {
  type = object({
    enable             = bool
    subnet_ids         = list(string)
    domain_name        = string
    engine_version     = string
    instance_type      = string
    instance_count     = number
    volume_size        = number
    security_group_ids = list(string)
  })
  description = "Input variables for configuring an AWS's OpenSearch domain"
}

variable "bedrock_region" {
  default     = "eu-central-1"
  description = "The AWS region for the bedrock models"
  type        = string
}
