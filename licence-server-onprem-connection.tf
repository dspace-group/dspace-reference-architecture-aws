data "aws_nat_gateway" "nat_gateways" {
  for_each  = toset(local.public_subnets)
  subnet_id = each.value
}

locals {
  licence_server_ports = {
    rlm           = 5053
    IVS_intempora = 60403
  }
  licence_access_points = concat([
    {
      cidr        = [for nat in data.aws_nat_gateway.nat_gateways : format("%s/32", nat.public_ip)]
      description = "cluster"
    }],
    var.onpremCidr != null ? [{
      cidr        = [var.onpremCidr]
      description = "onprem VM"
    }] : []
  )
}

resource "aws_lb" "ivs_onprem_licence_server_nlb" {
  count              = var.licenseServer ? 1 : 0
  name               = "ivs-onprem-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [local.public_subnets[1]]
  security_groups    = [aws_security_group.ivs_onprem_licence_server_sg[0].id]

  tags = var.tags
}

resource "aws_lb_target_group" "ivs_onprem_licence_server_tg" {
  for_each = local.licence_server_ports

  port               = each.value
  protocol           = "TCP"
  vpc_id             = local.vpc_id
  preserve_client_ip = false

  depends_on = [aws_lb.ivs_onprem_licence_server_nlb[0]]

  tags = var.tags
}

resource "aws_lb_target_group_attachment" "ivs_onprem_licence_server_tga" {
  for_each = local.licence_server_ports

  target_group_arn = aws_lb_target_group.ivs_onprem_licence_server_tg[each.key].arn
  target_id        = aws_instance.license_server[0].id
  port             = each.value
}

resource "aws_lb_listener" "ivs_onprem_licence_server_listener" {
  for_each = local.licence_server_ports

  load_balancer_arn = aws_lb.ivs_onprem_licence_server_nlb[0].arn
  protocol          = "TCP"
  port              = each.value

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ivs_onprem_licence_server_tg[each.key].arn
  }

  tags = var.tags
}

resource "aws_security_group" "ivs_onprem_licence_server_sg" {
  count       = var.licenseServer ? 1 : 0
  name        = "ivs-onprem-lb-sg"
  description = "Allow inbound traffic to licence server"
  vpc_id      = local.vpc_id

  dynamic "ingress" {
    for_each = flatten([
      for licence_access_point in local.licence_access_points : [
        for licence_server_port_key, licence_server_port in local.licence_server_ports : {
          cidr        = licence_access_point.cidr
          port_key    = licence_server_port_key
          port_value  = licence_server_port
          description = licence_access_point.description
        }
      ]
    ])
    content {
      description      = "Allow ingoing ${ingress.value.description} RTMaps licence request (${ingress.value.port_key})"
      from_port        = ingress.value.port_value
      to_port          = ingress.value.port_value
      protocol         = "tcp"
      cidr_blocks      = ingress.value.cidr
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  }

  egress = [
    {
      description      = "Allow all outgoing traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = var.tags
}

resource "aws_route53_record" "ivs_onprem_licence_server_dns" {
  count   = var.licenseServer ? 1 : 0 && var.enable_route53 ? 1 : 0
  zone_id = data.aws_route53_zone.primary[0].zone_id
  name    = var.route53_rtmaps_licence
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.ivs_onprem_licence_server_nlb[0].dns_name]
}
