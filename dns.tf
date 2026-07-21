data "aws_route53_zone" "primary" {
  count = var.enable_route53 ? 1 : 0
  name  = var.hosted_zone
}

resource "aws_route53_record" "dns_frontend" {
  count   = var.enable_route53 ? 1 : 0
  zone_id = data.aws_route53_zone.primary[0].zone_id
  name    = "simphera"
  type    = "CNAME"
  ttl     = "300"
  records = [module.main_alb[0].dns_name]
}
