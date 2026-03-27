locals {
  dashboards = var.cloudwatch_observability_config.enable ? [
    "jobs",
    "license_usage",
    "quicksearch_logs"
  ] : []
}

resource "aws_cloudwatch_dashboard" "cloudwatch_dashboard" {
  for_each       = toset(local.dashboards)
  dashboard_name = each.value
  dashboard_body = templatefile("${path.module}/templates/cloudwatch_dashboards/${each.value}.json", {
    region       = local.region,
    cluster_name = var.infrastructurename
  })
}
