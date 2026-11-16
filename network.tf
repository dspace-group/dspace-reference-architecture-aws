module "vpc" {
  count                = local.create_vpc ? 1 : 0
  source               = "terraform-aws-modules/vpc/aws"
  version              = "v5.8.1"
  name                 = "${var.infrastructure_name}-vpc"
  cidr                 = var.vpc.cidr_block
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = var.vpc.private_subnets_cidrs
  public_subnets       = var.vpc.public_subnets_cidrs
  enable_nat_gateway   = true
  create_igw           = true
  enable_dns_hostnames = true
  single_nat_gateway   = true
  tags                 = var.tags
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                          = "1"
    "purpose"                                         = "public"
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"                 = "1"
    "purpose"                                         = "private"
  }
}
