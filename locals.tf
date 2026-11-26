locals {
  # Network
  create_vpc = var.vpc.id == null
  vpc_id     = local.create_vpc ? module.vpc[0].vpc_id : var.vpc.id
  vpc_cidr   = local.create_vpc ? module.vpc[0].vpc_cidr_block : data.aws_vpc.preconfigured[0].cidr_block

  lookup_private_subnets = !local.create_vpc && var.vpc.private_subnets_ids == null
  lookup_public_subnets  = !local.create_vpc && var.vpc.public_subnets_ids == null

  private_subnets_ids = local.create_vpc ? module.vpc[0].private_subnets : (local.lookup_private_subnets ? data.aws_subnets.private[0].ids : var.vpc.private_subnets_ids)
  public_subnets_ids  = local.create_vpc ? module.vpc[0].public_subnets : (local.lookup_public_subnets ? data.aws_subnets.public[0].ids : var.vpc.public_subnets_ids)

  # EKS
  eks_cluster_name = var.infrastructure_name

  # KMS
  kms_cloudwatch_key_arn = var.aws_managed_kms ? null : aws_kms_key.cloudwatch_log_group[0].arn

  # AWS Context
  aws_context = {
    caller_identity_account_id = data.aws_caller_identity.current.account_id
    partition_dns_suffix       = data.aws_partition.current.dns_suffix
    partition                  = data.aws_partition.current.partition
    region_name                = data.aws_region.current.region
    iam_issuer_arn             = data.aws_iam_session_context.current.issuer_arn
  }

  # S3 policies
  s3_ssl_policy     = jsondecode(templatefile("${path.module}/templates/s3_ssl_policy.json", { bucket = aws_s3_bucket.logs_bucket.bucket }))
  s3_logging_policy = jsondecode(templatefile("${path.module}/templates/s3_log_policy.json", { bucket = aws_s3_bucket.logs_bucket.bucket, account_id = local.aws_context.caller_identity_account_id }))
  log_bucket_policy = {
    Version   = "2012-10-17"
    Statement = concat(local.s3_ssl_policy.Statement, local.s3_logging_policy.Statement)
  }

  # License server
  license_server_identifier  = "${var.infrastructure_name}-license-server"
  license_server_bucket_name = "${local.license_server_identifier}-bucket"

  # Patching
  patching_identifier = "${var.infrastructure_name}-patching"

  # Node groups
  gpu_node_groups = {
    for k, v in var.eks.gpu_node_groups : k => merge(v, {
      k8s_labels = merge(v.k8s_labels, { "gpu-driver" = v.driver_version })
    })
  }
  gpu_driver_versions = distinct(flatten([for g in var.eks.gpu_node_groups : g.driver_versions]))
  gpu_node_tolerations = [
    for t in distinct(flatten([for g in var.eks.gpu_node_groups : g.k8s_taints])) : {
      key      = t.key
      operator = "Equal"
      value    = t.value
      effect   = lookup({ NO_SCHEDULE = "NoSchedule", NO_EXECUTE = "NoExecute", PREFER_NO_SCHEDULE = "PreferNoSchedule" }, t.effect)
    }
  ]
  all_node_groups = merge(
    { for k, v in var.eks.node_groups : k => merge(v, { subnet_ids = local.private_subnets_ids }) },
    { for k, v in var.eks.gpu_node_groups : k => merge(v, { subnet_ids = local.private_subnets_ids }) },
  )

}
