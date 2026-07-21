resource "aws_apigatewayv2_api" "api" {
  name          = "${var.deployment_name}-apigw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_domain_name" "domain_name" {
  domain_name = "api.${var.domain_name}"
  domain_name_configuration {
    certificate_arn = aws_acm_certificate.api.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_route53_record" "dns_api" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "api.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_apigatewayv2_domain_name.domain_name.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.domain_name.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_apigatewayv2_api_mapping" "api_mapping" {
  api_id      = aws_apigatewayv2_api.api.id
  domain_name = aws_apigatewayv2_domain_name.domain_name.id
  stage       = aws_apigatewayv2_stage.stage.id
}

resource "aws_security_group" "gateway_sg" {
  name        = "${var.deployment_name}-apigw-securitygroup"
  description = "IVS API Gateway VPC Link Security Group"
  vpc_id      = var.vpc_id

  egress = [
    {
      description      = "Allow outgoing HTTP traffic"
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
      description      = "Allow outgoing HTTPS traffic"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
}

resource "aws_apigatewayv2_vpc_link" "vpc_link" {
  name               = "${var.deployment_name}-apigw-vpclink"
  security_group_ids = [aws_security_group.gateway_sg.id]
  subnet_ids         = var.public_subnet_ids
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_apigatewayv2_authorizer" "jwt" {
  name             = "${var.deployment_name}-apigw-azuread-authorizer"
  api_id           = aws_apigatewayv2_api.api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  jwt_configuration {
    audience = [var.external_oidc.client_id]
    issuer   = var.external_oidc.issuer
  }
}

resource "aws_apigatewayv2_integration" "integration" {
  api_id             = aws_apigatewayv2_api.api.id
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.vpc_link.id
  integration_uri    = data.aws_lb_listener.secure.arn
  tls_config {
    server_name_to_verify = var.domain_name
  }
  request_parameters = {
    "overwrite:header.Host" = "${var.domain_name}"
  }
}

resource "aws_apigatewayv2_route" "route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.integration.id}"

  authorizer_id      = aws_apigatewayv2_authorizer.jwt.id
  authorization_type = "JWT"
}
