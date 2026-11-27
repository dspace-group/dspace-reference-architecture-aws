variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "instance_identifier" {
  type = string
}

variable "database" {
  type = object({
    db_name                    = string
    postgresqlApplyImmediately = bool
    postgresqlStorage          = number
    postgresqlMaxStorage       = number
    postgresqlVersion          = string
    db_instance_type           = string
    enable_deletion_protection = bool
    multi_az                   = bool
    private_subnets_ids        = list(string)
    cloudwatch_retention       = number
    secret_name                = string
  })
}

variable "kms_cloudwatch_key_arn" {
  type = string
}

variable "tags" {
  type = map(string)
}
