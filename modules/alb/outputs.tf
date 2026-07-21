output "dns_name" {
  value = aws_lb.application_load_balancer.dns_name
}

output "arn" {
  value = aws_lb.application_load_balancer.arn
}
