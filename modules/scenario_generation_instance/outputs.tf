output "backup_vaults" {
  description = "Backups vaults created for the Scenario Generation instance."
  value       = [aws_backup_vault.scenario_generation[*].name]
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
  value       = try(aws_opensearch_domain.scenario_generation_opensearch[0].endpoint, null)
}

output "ragcore_service_account" {
  description = "K8s service account name with access to OpenSearch"
  value       = local.ragcore_opensearch_bedrock_serviceaccount
}

output "backend_service_account" {
  description = "K8s service account name with access to OpenSearch"
  value       = local.backend_opensearch_bedrock_serviceaccount
}
