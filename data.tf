data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
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

