locals {
  # Network
  create_vpc = var.vpc.id == null
  vpc_id     = local.create_vpc ? module.vpc[0].vpc_id : var.vpc.id

  lookup_private_subnets = !local.create_vpc && var.vpc.private_subnets_ids == null
  lookup_public_subnets  = !local.create_vpc && var.vpc.public_subnets_ids == null

  private_subnets_ids = local.create_vpc ? module.vpc[0].private_subnets : (local.lookup_private_subnets ? data.aws_subnets.private[0].ids : var.vpc.private_subnets_ids)
  public_subnets_ids  = local.create_vpc ? module.vpc[0].public_subnets : (local.lookup_public_subnets ? data.aws_subnets.public[0].ids : var.vpc.public_subnets_ids)

  # EKS
  eks_cluster_name = var.infrastructure_name
}
