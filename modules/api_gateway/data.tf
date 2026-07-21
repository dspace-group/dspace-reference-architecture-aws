data "aws_route53_zone" "hosted_zone" {
  name         = var.hosted_zone_name
  private_zone = false
}

data "aws_lb" "network_loadbalancer" {
  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

data "aws_lb_listener" "secure" {
  load_balancer_arn = data.aws_lb.network_loadbalancer.arn
  port              = 443
}
