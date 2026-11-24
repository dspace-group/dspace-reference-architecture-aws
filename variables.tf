variable "infrastructure_name" {
  description = "Name of the infrastructure"
  type        = string
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
    cloudwatch_retention       = number
    secret_name                = string
  })
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

variable "eks" {
  type = object({
    version        = string
    api_subnet_ids = optional(list(string), [])
    map_principals = optional(list(object({
      arn    = string
      groups = list(string)
    })), [])
    cloudwatch_log_group_retention = optional(number)
    node_groups = map(object({
      node_group_name   = string
      instance_types    = list(string)
      capacity_type     = optional(string, "ON_DEMAND")
      subnet_ids        = list(string)
      max_size          = number
      min_size          = number
      custom_ami_id     = optional(string, "")
      ami_type          = optional(string, "AL2023_x86_64_STANDARD")
      block_device_name = optional(string, "/dev/xvdb")
      volume_size       = number
      k8s_labels        = optional(map(string), {})
      k8s_taints = optional(list(object({
        key    = string
        value  = string
        effect = string
      })), [])
    }))
  })
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

variable "vpc_cni_addon_configuration" {
  description = "A YAML string of the configuration values to be applied to the AWS VPC CNI addon. For a list of valid configuration values run `aws eks describe-addon-configuration` for the vpc-cni, as described here: https://docs.aws.amazon.com/cli/latest/reference/eks/describe-addon-versions.html)"
  type        = string
  default     = <<-YAML
    enableNetworkPolicy: "true"
    YAML
}

variable "ingress_nginx_config" {
  type = object({
    enable          = bool
    helm_repository = optional(string, "https://kubernetes.github.io/ingress-nginx")
    helm_version    = optional(string, "4.12.1")
    chart_values = optional(string, <<-YAML
controller:
  images:
    registry: "registry.k8s.io"
  service:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
  allowSnippetAnnotations: true
  config:
    strict-validate-path-type: false
    annotations-risk-level: Critical
YAML
    )
  })
  description = "Input configuration for ingress-nginx service deployed with helm release. By setting key 'enable' to 'true', ingress-nginx service will be deployed. 'helm_repository' is an URL for the repository of ingress-nginx helm chart, where 'helm_version' is its respective version of a chart. 'chart_values' is used for changing default values.yaml of an ingress-nginx chart."
  default = {
    enable = false
  }
}

variable "cloudwatch_observability_config" {
  type = object({
    enable           = bool
    retention_period = number
  })
  description = "Input configuration for AWS EKS add-on amazon-cloudwatch-observability. By setting key 'enable' to 'true', amazon-cloudwatch-observability add-on is deployed."
  default = {
    enable           = false
    retention_period = 30
  }
}

variable "traefik_config" {
  type = object({
    enable          = bool
    chain_mode      = optional(bool, false)
    helm_repository = optional(string, "https://helm.traefik.io/traefik")
    helm_version    = optional(string, "40.2.0")
    chart_values    = optional(string, "")
  })
  description = "Input configuration for Traefik ingress controller. Deployed in front of ingress-nginx when using chaining mode."
  default = {
    enable = false
  }
}

variable "cluster_autoscaler_config" {
  type = object({
    enable          = optional(bool, true)
    helm_repository = optional(string, "https://kubernetes.github.io/autoscaler")
    helm_version    = optional(string, "9.52.1")
    chart_values = optional(string, <<-YAML

    YAML
    )
  })
  description = "Input configuration for cluster-autoscaler deployed with helm release. By setting key 'enable' to 'true', cluster-autoscaler release will be deployed. 'helm_repository' is an URL for the repository of cluster-autoscaler helm chart, where 'helm_version' is its respective version of a chart. 'chart_values' is used for changing default values.yaml of a cluster-autoscaler chart."
  default     = {}
}

variable "coredns_config" {
  type = object({
    enable               = optional(bool, true)
    configuration_values = optional(string, null)
  })
  description = "Input configuration for AWS EKS add-on coredns. By setting key 'enable' to 'true', coredns add-on is deployed. Key 'configuration_values' is used to change add-on configuration. Its content should follow add-on configuration schema (see https://aws.amazon.com/blogs/containers/amazon-eks-add-ons-advanced-configuration/)."
  default = {
    enable = true
  }
}

variable "efs_csi_config" {
  type = object({
    enable = optional(bool, true)
  })
  description = "Input configuration for AWS EKS add-on efs csi. By setting key 'enable' to 'true', efs csi add-on is deployed."
  default = {
    enable = true
  }
}

variable "s3_csi_config" {
  type = object({
    enable = optional(bool, false)
    configuration_values = optional(string, <<-YAML
node:
    tolerateAllTaints: true
YAML
    )
  })
  description = "Input configuration for AWS EKS add-on aws-mountpoint-s3-csi-driver. By setting key 'enable' to 'true', aws-mountpoint-s3-csi-driver add-on is deployed. Key 'configuration_values' is used to change add-on configuration. Its content should follow add-on configuration schema (see https://aws.amazon.com/blogs/containers/amazon-eks-add-ons-advanced-configuration/)."
  default = {
    enable = false
  }
}

variable "aws_load_balancer_controller_config" {
  type = object({
    enable          = optional(bool, false)
    helm_repository = optional(string, "https://aws.github.io/eks-charts")
    helm_version    = optional(string, "1.4.5")
    chart_values = optional(string, <<-YAML

    YAML
    )
  })
  description = "Input configuration for load_balancer_controller deployed with helm release. By setting key 'enable' to 'true', load_balancer_controller release will be deployed. 'helm_repository' is an URL for the repository of load_balancer_controller helm chart, where 'helm_version' is its respective version of a chart. 'chart_values' is used for changing default values.yaml of a load_balancer_controller chart."
  default = {
    enable = false
  }
}

variable "gpu_operator_config" {
  type = object({
    enable          = optional(bool, true)
    helm_repository = optional(string, "https://helm.ngc.nvidia.com/nvidia")
    helm_version    = optional(string, "v26.3.2")
    driver_versions = optional(list(string), ["595.71.05"])
    chart_values = optional(string, <<-YAML

    YAML
    )
  })
  description = "Input configuration for the GPU operator chart deployed with helm release. By setting key 'enable' to 'true', GPU operator will be deployed. 'helm_repository' is an URL for the repository of the GPU operator helm chart, where 'helm_version' is its respective version of a chart. 'chart_values' is used for changing default values.yaml of the GPU operator chart."
  default = {
    enable = false
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
