variable "infrastructure_name" {
  description = "Name of the infrastructure"
  type        = string
}

variable "vpc" {
  description = "VPC configuration"
  type = object({
    id                    = optional(string)
    cidr_block            = string
    private_subnets_cidrs = list(string)
    public_subnets_cidrs  = list(string)
    private_subnets_ids   = optional(list(string))
    public_subnets_ids    = optional(list(string))
    flow_logs_retention   = optional(number)
  })
  default = {
    cidr_block            = "10.1.0.0/18"
    private_subnets_cidrs = ["10.1.0.0/22", "10.1.4.0/22", "10.1.8.0/22"]
    public_subnets_cidrs  = ["10.1.12.0/22", "10.1.16.0/22", "10.1.20.0/22"]
  }
}

variable "cloudwatch_retention" {
  description = "Retention period for CloudWatch logs"
  type        = number
  default     = 7
}

variable "aws_managed_kms" {
  type        = bool
  description = "Flag for using AWS managed KMS keys instead of customer managed KMS keys for EKS resources, cloudwatch log groups and S3 bucket logs."
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
