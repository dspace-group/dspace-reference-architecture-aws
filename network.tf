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

# VPC logging
## [EC2.6] VPC flow logging should be enabled in all VPCs
## https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards-fsbp-controls.html#fsbp-ec2-6
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count             = local.create_vpc ? 1 : 0
  name              = "/aws/vpc/${var.infrastructure_name}"
  retention_in_days = coalesce(var.vpc.flow_logs_retention, var.cloudwatch_retention)
  kms_key_id        = local.kms_cloudwatch_key_arn
  tags              = var.tags
}

resource "aws_flow_log" "vpc" {
  count           = local.create_vpc ? 1 : 0
  iam_role_arn    = aws_iam_role.vpc_flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  traffic_type    = "ALL"
  vpc_id          = local.vpc_id
  tags            = var.tags
}

resource "aws_iam_role" "vpc_flow_logs" {
  count              = local.create_vpc ? 1 : 0
  name               = "${var.infrastructure_name}-flowlogs-role"
  description        = "AWS IAM service role for VPC flow logs."
  assume_role_policy = <<-EOF
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
            "Service": "vpc-flow-logs.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
    }
    EOF
  tags               = var.tags
}

resource "aws_iam_policy" "vpc_flow_logs" {
  count  = local.create_vpc ? 1 : 0
  name   = "${var.infrastructure_name}-flowlogs-policy"
  policy = <<-EOF
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Action": [
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams"
        ],
        "Effect": "Allow",
        "Resource": "*"
        }
    ]
    }
    EOF
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "vpc_flow_logs" {
  count      = local.create_vpc ? 1 : 0
  role       = aws_iam_role.vpc_flow_logs[0].id
  policy_arn = aws_iam_policy.vpc_flow_logs[0].arn
}
