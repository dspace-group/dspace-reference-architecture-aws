resource "aws_instance" "license_server" {
  count                   = var.license_server.enable ? 1 : 0
  ami                     = data.aws_ami.amazon_linux_kernel5.id
  instance_type           = var.license_server.instance_type
  iam_instance_profile    = aws_iam_instance_profile.license_server_profile[0].name
  subnet_id               = local.private_subnets_ids[0]
  disable_api_termination = true
  vpc_security_group_ids  = [aws_security_group.license_server[0].id]

  metadata_options {
    # [EC2.8] EC2 instances should use IMDSv2
    # https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards-fsbp-controls.html#fsbp-ec2-8
    http_endpoint = "enabled"
    http_tokens   = "required" # Require session token for Instance Metadata Service Version 2 (IMDSv2)
  }
  user_data = <<-EOF
    #!/bin/bash
    yum update -y

    wget -O CodeMeter.rpm "${var.license_server.codemeter}"
    yum -y localinstall CodeMeter.rpm
    systemctl stop codemeter
    sed -i -e '/IsNetworkServer=/ s/=.*/=1/' /etc/wibu/CodeMeter/Server.ini
    systemctl start codemeter
    systemctl enable codemeter

    echo "Reload the services"
    systemctl daemon-reload
    EOF

  lifecycle {
    ignore_changes = [
      ami,
    ]
  }
  tags = merge(var.tags, { "Name" = local.license_server_identifier, "Patch Group" = local.patching_identifier })
}

data "aws_ami" "amazon_linux_kernel5" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-202*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}
resource "aws_iam_role" "license_server" {
  count       = var.license_server.enable ? 1 : 0
  description = "IAM role used for the license server instance profile."
  name        = "${local.license_server_identifier}-role"
  tags        = var.tags
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "license_server" {
  count       = var.license_server.enable ? 1 : 0
  name        = "${local.license_server_identifier}-policy"
  description = "Allows access to S3 bucket and Secure Session Manager connections."
  policy      = templatefile("${path.module}/templates/license_server_policy.json", { bucket = local.license_server_bucket_name })
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "license_server" {
  for_each = var.license_server.enable ? {
    s3  = aws_iam_policy.license_server[0].arn
    ssm = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  } : {}
  role       = aws_iam_role.license_server[0].name
  policy_arn = each.value
}

resource "aws_s3_bucket" "license_server" {
  count         = var.license_server.enable ? 1 : 0
  bucket        = local.license_server_bucket_name
  tags          = var.tags
  force_destroy = false
}

# [S3.5] S3 buckets should require requests to use Secure Socket Layer
resource "aws_s3_bucket_policy" "license_server_bucket_ssl" {
  count  = var.license_server.enable ? 1 : 0
  bucket = aws_s3_bucket.license_server[0].id
  policy = templatefile("${path.module}/templates/s3_ssl_policy.json", { bucket = aws_s3_bucket.license_server[0].id })
}

resource "aws_s3_bucket_logging" "license_server_bucket_logging" {
  count         = var.license_server.enable ? 1 : 0
  bucket        = aws_s3_bucket.license_server[0].id
  target_bucket = aws_s3_bucket.logs_bucket.id
  target_prefix = "logs/bucket/${aws_s3_bucket.license_server[0].id}/"
}

resource "aws_iam_instance_profile" "license_server_profile" {
  count = var.license_server.enable ? 1 : 0
  name  = local.license_server_identifier
  role  = aws_iam_role.license_server[0].name
}

resource "aws_security_group" "license_server" {
  count                  = var.license_server.enable ? 1 : 0
  name                   = "${local.license_server_identifier}-sg"
  description            = "Security group for ${local.license_server_identifier} license server"
  vpc_id                 = local.vpc_id
  revoke_rules_on_delete = true
  tags                   = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "license_server_eks" {
  count                        = var.license_server.enable ? 1 : 0
  security_group_id            = aws_security_group.license_server[0].id
  description                  = "Inbound TCP on port 22350 from kubernetes nodes security group"
  from_port                    = 22350
  to_port                      = 22350
  ip_protocol                  = "tcp"
  referenced_security_group_id = module.eks.cluster_primary_security_group_id
}

resource "aws_vpc_security_group_egress_rule" "license_server_all" {
  count             = var.license_server.enable ? 1 : 0
  security_group_id = aws_security_group.license_server[0].id
  description       = "allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
