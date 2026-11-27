data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_partition" "current" {}

data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}

data "aws_subnets" "private" {
  count = local.lookup_private_subnets ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [var.vpc.id]
  }

  tags = {
    purpose = "private"
  }
}

data "aws_subnets" "public" {
  count = local.lookup_public_subnets ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [var.vpc.id]
  }

  tags = {
    purpose = "public"
  }
}

data "aws_vpc" "preconfigured" {
  count = local.create_vpc ? 0 : 1
  id    = var.vpc.id
}

data "aws_ami" "gpu_ami" {
  count       = var.eks.enable_gpu_node_groups ? 1 : 0
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["*ubuntu-eks/k8s_${var.eks.kubernetes_version}/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server*"]
  }
}
