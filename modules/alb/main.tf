resource "aws_security_group" "alb" {
  name        = "${var.deployment_name}-alb-sg"
  description = "IVS Main Application Load Balancer Security Group"
  vpc_id      = var.vpc_id

  ingress = [
    {
      description      = "Allow ingoing HTTP traffic"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "HTTPS from everywhere"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress = [
    {
      description      = "All traffic To everywhere"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
}

resource "aws_lb" "application_load_balancer" {
  name                       = "${var.deployment_name}-alb"
  drop_invalid_header_fields = "true"
  enable_deletion_protection = "true"
  enable_http2               = "true"
  idle_timeout               = "60"
  internal                   = var.internal
  ip_address_type            = "ipv4"
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]

  subnets = var.public_subnet_ids
}

resource "aws_route53_record" "alb" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = lower(aws_lb.application_load_balancer.dns_name)
    zone_id                = aws_lb.application_load_balancer.zone_id
    evaluate_target_health = false
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  certificate_arn = var.wildcard_cert_arn

  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = "443"
  protocol          = "HTTPS"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "openid" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 1

  action {
    type  = "authenticate-oidc"
    order = 1

    authenticate_oidc {
      issuer                 = var.external_oidc.issuer
      authorization_endpoint = var.external_oidc.authorization_endpoint
      token_endpoint         = var.external_oidc.token_endpoint
      user_info_endpoint     = var.external_oidc.user_info_endpoint
      client_id              = var.external_oidc.client_id
      client_secret          = local.oidc_secrets.authentication_openid_client_secret
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.targetgroup.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_lb_target_group" "targetgroup" {
  name        = "${var.deployment_name}-alb-tg"
  port        = 443
  protocol    = "HTTPS"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    path     = "/healthz"
    protocol = "HTTPS"
  }
}
