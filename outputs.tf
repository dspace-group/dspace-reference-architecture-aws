output "account_id" {
  description = "The AWS account id used for creating resources."
  value       = data.aws_caller_identity.current.account_id
}

# output "backup_vaults" {
#   description = "Backups vaults managed by terraform."
#   value = {
#     simphera = {
#       for name, instance in module.simphera_instance :
#       name => flatten(instance.backup_vaults)
#     }
#     ivs = {
#       for name, instance in module.ivs_instance :
#       name => flatten(instance.backup_vaults)
#     }
#   }
# }

output "database_identifiers" {
  description = "Identifiers of the databases from all instances."
  value       = module.simphera_common[*].database_identifier
}

output "database_endpoint" {
  description = "Endpoint of the shareddatabase"
  value       = module.simphera_common[*].database_endpoint
}

output "managed_buckets" {
  description = "S3 buckets managed by terraform."
  value       = local.managed_buckets
}

output "eks_cluster_id" {
  description = "Amazon EKS Cluster Name"
  value       = module.eks.eks_cluster_id
}

output "opensearch_domain_endpoint" {
  description = "List of OpenSearch Domains endpoints of IVS instances"
  value       = module.data_management[*].opensearch_domain_endpoint
}

# output "ivs_buckets_service_accounts" {
#   description = "List of K8s service account names with access to the IVS buckets"
#   value       = [for name, instance in module.ivs_instance : instance.ivs_buckets_service_account]
# }
