
locals {
  infrastructurename                        = var.infrastructurename
  log_group_name                            = "/${module.eks.cluster_id}/worker-fluentbit-logs"
  allowed_account_ids                       = [var.account_id]
  license_server_role                       = "${local.infrastructurename}-license-server-role"
  license_server_policy                     = "${local.infrastructurename}-license-server-policy"
  license_server_bucket_name                = "${local.infrastructurename}-license-server-bucket"
  license_server                            = "${local.infrastructurename}-license-server"
  license_server_instance_profile           = "${local.infrastructurename}-license-server-instance-profile"
  flowlogs_cloudwatch_loggroup              = "/aws/vpc/${module.eks.cluster_id}"
  patch_manager_cloudwatch_loggroup_scan    = "/aws/ssm/${module.eks.cluster_id}/scan"
  patch_manager_cloudwatch_loggroup_install = "/aws/ssm/${module.eks.cluster_id}/install"
  patchgroupid                              = "${var.infrastructurename}-patch-group"
  s3_instance_buckets                       = flatten([for name, instance in module.simphera_instance : instance.s3_buckets])
  license_server_bucket                     = var.licenseServer ? [aws_s3_bucket.license_server_bucket[0].bucket] : []
  s3_buckets                                = concat(local.s3_instance_buckets, [aws_s3_bucket.bucket_logs.bucket], local.license_server_bucket)

  default_managed_node_pools = {
    "default" = {
      instance_types = var.linuxNodeSize
      subnet_ids     = module.vpc.private_subnets
      desired_size   = var.linuxNodeCountMin
      max_size       = var.linuxNodeCountMax
      min_size       = var.linuxNodeCountMin
    },
    "execnodes" = {
      instance_types = var.linuxExecutionNodeSize
      subnet_ids     = module.vpc.private_subnets
      desired_size   = var.linuxExecutionNodeCountMin
      max_size       = var.linuxExecutionNodeCountMax
      min_size       = var.linuxExecutionNodeCountMin
      labels = {
        "purpose" = "execution"
      }
      taints = [
        {
          key      = "purpose",
          value    = "execution",
          "effect" = "NO_SCHEDULE"
        }
      ]
    }

  }

  gpu_node_pool = {
    "gpuexecnodes" = {
      instance_types = var.gpuNodeSize
      subnet_ids     = module.vpc.private_subnets
      desired_size   = var.gpuNodeCountMin
      max_size       = var.gpuNodeCountMax
      min_size       = var.gpuNodeCountMin
      disk_size      = var.gpuNodeDiskSize
      labels = {
        "purpose" = "gpu"
      }
      taints = [
        {
          key      = "purpose",
          value    = "gpu",
          "effect" = "NO_SCHEDULE"
        }
      ]
    }
  }
}
