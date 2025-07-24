output "backup_vaults" {
  description = "Backups vaults created for the Scenario Generation instance."
  value       = [aws_backup_vault.backup_vault[*].name]
}

output "database_identifiers" {
  description = "Identifiers of the Scenario Generation databases created for this Scenario Generation instance."
  value       = [aws_db_instance.scenario_generation.identifier]
}

output "database_endpoints" {
  description = "Endpoints of the Scenario Generation databases created for this Scenario Generation instance."
  value       = [aws_db_instance.scenario_generation.endpoint]
}

output "opensearch_domain_endpoint" {
  description = "OpenSearch Domain endpoint"
  value       = try(aws_opensearch_domain.opensearch[0].endpoint, null)
}

output "opensearch_service_account" {
  description = "K8s service account name with access to OpenSearch"
  value       = local.opensearch_serviceaccount
}
