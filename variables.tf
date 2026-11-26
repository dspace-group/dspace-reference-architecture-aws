variable "infrastructure_name" {
  description = "Name of the infrastructure"
  type        = string
  default     = "simphera-infra"
}

variable "database" {
  description = <<-EOT
    Configuration of the PostgreSQL RDS instance used by SIMPHERA.
      db_name: Name of the database created in the instance.
      postgresqlApplyImmediately: Apply modifications immediately instead of in the next maintenance window.
      postgresqlStorage: Initial allocated storage in GiB.
      postgresqlMaxStorage: Upper limit in GiB for storage autoscaling.
      postgresqlVersion: PostgreSQL major version.
      db_instance_type: RDS instance class, e.g. db.t4g.large.
      enable_deletion_protection: Protect the instance against deletion.
      multi_az: Deploy a standby instance in a second availability zone.
      secret_name: Name of the Secrets Manager secret holding the database credentials.
      cloudwatch_retention: (optional) Retention in days of the database CloudWatch logs; defaults to the global cloudwatch_retention.
  EOT
  type = object({
    db_name                    = string
    postgresqlApplyImmediately = bool
    postgresqlStorage          = number
    postgresqlMaxStorage       = number
    postgresqlVersion          = string
    db_instance_type           = string
    enable_deletion_protection = bool
    multi_az                   = bool
    secret_name                = string
    cloudwatch_retention       = optional(number)
  })
  default = {
    db_name                    = "simphera"
    postgresqlApplyImmediately = true
    postgresqlStorage          = 20
    postgresqlMaxStorage       = 100
    postgresqlVersion          = "15"
    db_instance_type           = "db.t4g.large"
    enable_deletion_protection = false
    multi_az                   = false
    secret_name                = "simphera-db-secret"
  }
}

variable "data_management" {
  description = <<-EOT
    Configuration of the SIMPHERA data management components (S3 buckets, OpenSearch).
      enable: (optional) Deploy data management; defaults to true.
      buckets[].create: Create the bucket.
      buckets[].name: Name of the bucket.
      buckets[].versioning: Enable object versioning.
      buckets[].logging: Enable server access logging to the logging bucket.
      opensearch.enable: Deploy an OpenSearch domain.
      opensearch.domain_name: Name of the OpenSearch domain.
      opensearch.engine_version: OpenSearch engine version, e.g. OpenSearch_2.17.
      opensearch.instance_type: Instance type of the data nodes.
      opensearch.instance_count: Number of data nodes.
      opensearch.volume_size: EBS volume size in GiB per data node.
      opensearch.master_user_secret_name: Name of the Secrets Manager secret holding the master user credentials.
      k8s_namespace: Kubernetes namespace for the data management components.
  EOT
  type = object({
    enable = optional(bool, true)
    buckets = list(object({
      create     = bool
      name       = string
      versioning = bool
      logging    = bool
    }))
    opensearch = object({
      enable                  = bool
      domain_name             = string
      engine_version          = string
      instance_type           = string
      instance_count          = number
      volume_size             = number
      master_user_secret_name = string
    })
    k8s_namespace = string
  })
  default = {
    enable = true
    buckets = [
      {
        create     = true
        name       = "raw_data_storage"
        versioning = false
        logging    = false
      },
      {
        create     = true
        name       = "data_storage"
        versioning = false
        logging    = false
      }
    ]
    opensearch = {
      enable                  = false
      domain_name             = "data_management_domain"
      engine_version          = "OpenSearch_2.17"
      instance_type           = "m7g.medium.search"
      instance_count          = 1
      volume_size             = 100
      master_user_secret_name = "opensearch-master-user"
    }
    k8s_namespace = "datamanagement"
  }
}

variable "vpc" {
  description = <<-EOT
    VPC configuration. Set id and the subnet ids to use an existing VPC, otherwise a new VPC is created.
      id: (optional) Id of an existing VPC.
      cidr_block: CIDR block of the VPC.
      private_subnets_cidrs: CIDR blocks of the private subnets, one per availability zone.
      public_subnets_cidrs: CIDR blocks of the public subnets, one per availability zone.
      private_subnets_ids: (optional) Ids of existing private subnets.
      public_subnets_ids: (optional) Ids of existing public subnets.
      flow_logs_retention: (optional) Retention in days of the VPC flow logs.
  EOT
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
  description = <<-EOT
    Configuration of the EKS cluster and its managed node groups.
      kubernetes_version: Kubernetes version of the cluster.
      api_subnet_ids: (optional) Subnet ids for the cluster API endpoint; defaults to [].
      map_principals[].arn: ARN of the IAM principal granted cluster access.
      map_principals[].groups: Kubernetes groups assigned to the principal.
      cloudwatch_log_group_retention: (optional) Retention in days of the cluster log group.
      node_groups.<key>.node_group_name: Name of the node group.
      node_groups.<key>.instance_types: Instance types, in order of preference.
      node_groups.<key>.capacity_type: (optional) ON_DEMAND or SPOT; defaults to ON_DEMAND.
      node_groups.<key>.max_size: Maximum number of nodes.
      node_groups.<key>.min_size: Minimum number of nodes.
      node_groups.<key>.custom_ami_id: (optional) Custom AMI id; defaults to "" (EKS optimized AMI).
      node_groups.<key>.ami_type: (optional) AMI type; defaults to AL2023_x86_64_STANDARD.
      node_groups.<key>.block_device_name: (optional) Device name of the data volume; defaults to /dev/xvdb.
      node_groups.<key>.volume_size: Size in GiB of the data volume.
      node_groups.<key>.k8s_labels: (optional) Kubernetes labels of the nodes; defaults to {}.
      node_groups.<key>.k8s_taints[]: (optional) Kubernetes taints of the nodes with key, value and effect (NO_SCHEDULE, PREFER_NO_SCHEDULE or NO_EXECUTE).
      enable_gpu_node_groups: (optional) Create the GPU node groups; defaults to false.
      gpu_node_groups.<key>.node_group_name: Name of the GPU node group.
      gpu_node_groups.<key>.instance_types: GPU instance types, in order of preference.
      gpu_node_groups.<key>.capacity_type: (optional) ON_DEMAND or SPOT; defaults to ON_DEMAND.
      gpu_node_groups.<key>.max_size: Maximum number of nodes.
      gpu_node_groups.<key>.min_size: Minimum number of nodes.
      gpu_node_groups.<key>.custom_ami_id: (optional) Custom AMI id; defaults to "".
      gpu_node_groups.<key>.block_device_name: (optional) Device name of the data volume; defaults to /dev/sda1.
      gpu_node_groups.<key>.volume_size: Size in GiB of the data volume.
      gpu_node_groups.<key>.driver_version: (optional) NVIDIA driver version; defaults to 595.71.05.
      gpu_node_groups.<key>.k8s_labels: (optional) Kubernetes labels of the nodes; defaults to {}.
      gpu_node_groups.<key>.k8s_taints[]: (optional) Kubernetes taints with key, value and effect.
  EOT
  type = object({
    kubernetes_version = string
    api_subnet_ids     = optional(list(string), [])
    map_principals = optional(list(object({
      arn    = string
      groups = list(string)
    })), [])
    cloudwatch_log_group_retention = optional(number)
    node_groups = map(object({
      node_group_name   = string
      instance_types    = list(string)
      capacity_type     = optional(string, "ON_DEMAND")
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
    enable_gpu_node_groups = optional(bool, false)
    gpu_node_groups = optional(map(object({
      node_group_name   = string
      instance_types    = list(string)
      capacity_type     = optional(string, "ON_DEMAND")
      max_size          = number
      min_size          = number
      custom_ami_id     = optional(string, "")
      block_device_name = optional(string, "/dev/sda1")
      volume_size       = number
      driver_version    = optional(string, "595.71.05")
      k8s_labels        = optional(map(string), {})
      k8s_taints = optional(list(object({
        key    = string
        value  = string
        effect = string
      })))
    })))
  })
  default = {
    kubernetes_version = "1.35"
    node_groups = {
      default = {
        node_group_name   = "default"
        instance_types    = ["m6a.4xlarge", "m5a.4xlarge", "m5.4xlarge", "m6i.4xlarge", "m4.4xlarge", "m7i.4xlarge", "m7a.4xlarge"]
        capacity_type     = "ON_DEMAND"
        max_size          = 3
        min_size          = 1
        ami_type          = "AL2023_x86_64_STANDARD"
        block_device_name = "/dev/xvdb"
        volume_size       = 200
      },
      execnodes = {
        node_group_name   = "execnodes"
        instance_types    = ["m6a.4xlarge", "m5a.4xlarge", "m5.4xlarge", "m6i.4xlarge", "m4.4xlarge", "m7i.4xlarge", "m7a.4xlarge"]
        capacity_type     = "ON_DEMAND"
        max_size          = 3
        min_size          = 1
        ami_type          = "AL2023_x86_64_STANDARD"
        block_device_name = "/dev/xvdb"
        volume_size       = 200
        k8s_labels = {
          "purpose" = "execution"
          "product" = "data_management"
        }
        k8s_taints = [
          {
            key      = "purpose",
            value    = "execution",
            "effect" = "NO_SCHEDULE"
          }
        ]
      }
    }
    enable_gpu_node_groups = false
    gpu_node_groups = {
      gpuexecnodes = {
        node_group_name   = "gpuexecnodes"
        instance_types    = ["g5.2xlarge"]
        capacity_type     = "ON_DEMAND"
        max_size          = 3
        min_size          = 1
        block_device_name = "/dev/sda1"
        volume_size       = 200
        driver_version    = "550.90.07"
        k8s_labels = {
          "purpose" = "gpu"
        }
        k8s_taints = [
          {
            key      = "purpose",
            value    = "gpu",
            "effect" = "NO_SCHEDULE"
          }
        ]
      }
    }
  }
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
  description = <<-EOT
    Configuration of ingress-nginx deployed as helm release.
      enable: Deploy ingress-nginx.
      helm_repository: (optional) URL of the helm chart repository.
      helm_version: (optional) Version of the helm chart.
      chart_values: (optional) YAML string overriding the default values.yaml of the chart.
  EOT
  default = {
    enable = false
  }
}

variable "cloudwatch_observability_config" {
  type = object({
    enable           = bool
    retention_period = number
  })
  description = <<-EOT
    Configuration of the AWS EKS add-on amazon-cloudwatch-observability.
      enable: Deploy the add-on.
      retention_period: Retention in days of the add-on log groups.
  EOT
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
  description = <<-EOT
    Configuration of the Traefik ingress controller, deployed in front of ingress-nginx when using chain mode.
      enable: Deploy Traefik.
      chain_mode: (optional) Chain Traefik in front of ingress-nginx; defaults to false.
      helm_repository: (optional) URL of the helm chart repository.
      helm_version: (optional) Version of the helm chart.
      chart_values: (optional) YAML string overriding the default values.yaml of the chart.
  EOT
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
  description = <<-EOT
    Configuration of cluster-autoscaler deployed as helm release.
      enable: (optional) Deploy cluster-autoscaler; defaults to true.
      helm_repository: (optional) URL of the helm chart repository.
      helm_version: (optional) Version of the helm chart.
      chart_values: (optional) YAML string overriding the default values.yaml of the chart.
  EOT
  default     = {}
}

variable "coredns_config" {
  type = object({
    enable               = optional(bool, true)
    configuration_values = optional(string, null)
  })
  description = <<-EOT
    Configuration of the AWS EKS add-on coredns.
      enable: (optional) Deploy the add-on; defaults to true.
      configuration_values: (optional) JSON/YAML add-on configuration following the add-on configuration schema.
  EOT
  default = {
    enable = true
  }
}

variable "efs_csi_config" {
  type = object({
    enable = optional(bool, true)
  })
  description = <<-EOT
    Configuration of the AWS EKS add-on efs csi.
      enable: (optional) Deploy the add-on; defaults to true.
  EOT
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
  description = <<-EOT
    Configuration of the AWS EKS add-on aws-mountpoint-s3-csi-driver.
      enable: (optional) Deploy the add-on; defaults to false.
      configuration_values: (optional) JSON/YAML add-on configuration following the add-on configuration schema.
  EOT
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
  description = <<-EOT
    Configuration of the AWS load balancer controller deployed as helm release.
      enable: (optional) Deploy the controller; defaults to false.
      helm_repository: (optional) URL of the helm chart repository.
      helm_version: (optional) Version of the helm chart.
      chart_values: (optional) YAML string overriding the default values.yaml of the chart.
  EOT
  default = {
    enable = false
  }
}

variable "gpu_operator_config" {
  type = object({
    enable          = optional(bool, true)
    helm_repository = optional(string, "https://helm.ngc.nvidia.com/nvidia")
    helm_version    = optional(string, "v26.3.2")
    chart_values = optional(string, <<-YAML

    YAML
    )
  })
  description = <<-EOT
    Configuration of the NVIDIA GPU operator deployed as helm release.
      enable: (optional) Deploy the GPU operator; defaults to true.
      helm_repository: (optional) URL of the helm chart repository.
      helm_version: (optional) Version of the helm chart.
      chart_values: (optional) YAML string overriding the default values.yaml of the chart.
  EOT
  default = {
    enable = false
  }
}

variable "cloudwatch_retention" {
  description = "Retention period for CloudWatch logs"
  type        = number
  default     = 7
}

variable "bucket_logging_retention" {
  description = "Retention in days of the S3 access logs stored in the logging bucket"
  type        = number
  default     = 7
}

variable "aws_managed_kms" {
  type        = bool
  description = "Flag for using AWS managed KMS keys instead of customer managed KMS keys for EKS resources, cloudwatch log groups and S3 bucket logs."
  default     = false
}

variable "license_server" {
  description = <<-EOT
    Configuration of the license server EC2 instance.
      enable: (optional) Deploy the license server; defaults to false.
      instance_type: (optional) EC2 instance type; defaults to t3a.large.
      codemeter: (optional) Download URL of the CodeMeter runtime installed on the instance.
  EOT
  type = object({
    enable        = optional(bool, false)
    instance_type = optional(string, "t3a.large")
    codemeter     = optional(string, "https://www.wibu.com/support/user/user-software/file/download/15803.html?tx_wibudownloads_downloadlist%5BdirectDownload%5D=directDownload&tx_wibudownloads_downloadlist%5BuseAwsS3%5D=0&cHash=8dba7ab094dec6267346f04fce2a2bcd")
  })
  default = {
    enable        = true
    instance_type = "t3a.large"
    codemeter     = "https://www.wibu.com/support/user/user-software/file/download/15803.html?tx_wibudownloads_downloadlist%5BdirectDownload%5D=directDownload&tx_wibudownloads_downloadlist%5BuseAwsS3%5D=0&cHash=8dba7ab094dec6267346f04fce2a2bcd"
  }
}

variable "patching" {
  description = <<-EOT
    Configuration of OS patching with AWS Systems Manager Patch Manager.
      enable: (optional) Enable patching; defaults to false.
      maintainance_duration: (optional) Duration in hours of the maintenance window; defaults to 3.
      scan_schedule: (optional) Cron expression of the patch scan; defaults to cron(0 0 * * ? *).
      install_schedule: (optional) Cron expression of the patch installation; defaults to cron(0 3 * * ? *).
      ssm_logs_retention: (optional) Retention in days of the SSM logs.
  EOT
  type = object({
    enable                = optional(bool, false)
    maintainance_duration = optional(number, 3)
    scan_schedule         = optional(string, "cron(0 0 * * ? *)")
    install_schedule      = optional(string, "cron(0 3 * * ? *)")
    ssm_logs_retention    = optional(number)
  })
  default = {
    enable                = false
    maintainance_duration = 3
    scan_schedule         = "cron(0 0 * * ? *)"
    install_schedule      = "cron(0 3 * * ? *)"
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    managed_by = "terraform"
    PRODUCT    = "SIMPHERA"
  }
}
