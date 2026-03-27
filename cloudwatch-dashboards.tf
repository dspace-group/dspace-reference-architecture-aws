resource "aws_cloudwatch_dashboard" "cloudwatch_dashboard" {
    dashboard_name = "jobs"
    dashboard_body = templatefile("${path.module}/templates/cloudwatch_dashboards/license_server_policy.json", {
        region = local.region
    })
}
