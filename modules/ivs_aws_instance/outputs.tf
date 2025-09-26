output "opensearch_domain_endpoint" {
  description = "OpenSearch Domain endpoint"
  value       = try(aws_opensearch_domain.opensearch[0].endpoint, null)
}

output "backup_vaults" {
  description = "Backups vaults created for the IVS instance."
  value       = [aws_backup_vault.backup_vault[*].name]
}

output "ivs_database_identifiers" {
  description = "Identifiers of the IVS database created for this IVS instance."
  value       = [var.enableIVSAuthentication ? aws_db_instance.ivs_authentication[0].identifier : ""]
}

output "ivs_buckets_service_account" {
  description = "K8s service account name with access to the IVS buckets"
  value       = local.ivs_buckets_service_account
}
