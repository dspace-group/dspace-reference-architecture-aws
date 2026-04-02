locals {
  dashboards = var.cloudwatch_observability_config.enable ? [
    "jobs",
    "license_usage"
  ] : []
}

resource "aws_cloudwatch_dashboard" "cloudwatch_dashboard" {
  for_each = {
    for id, name in local.dashboards :
    id => name
  }
  dashboard_name = "${var.infrastructurename}-${each.value}"
  dashboard_body = templatefile("${path.module}/templates/cloudwatch_dashboards/${each.value}.json", {
    region       = local.region,
    cluster_name = var.infrastructurename
  })
}
