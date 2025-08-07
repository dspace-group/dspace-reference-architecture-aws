output "account_id" {
  description = "The AWS account id used for creating resources."
  value       = local.account_id
}

output "backup_vaults" {
  description = "Backups vaults managed by terraform."
  value = {
    simphera = {
      for name, instance in module.simphera_instance :
      name => flatten(instance.backup_vaults)
    }
    ivs = {
      for name, instance in module.ivs_instance :
      name => flatten(instance.backup_vaults)
    }
    scenario_generation = {
      for name, instance in module.scenario_generation_instance :
      name => flatten(instance.backup_vaults)
    }
  }
}

output "database_identifiers" {
  description = "Identifiers of the databases from all instances."
  value = {
    simphera = {
      for name, instance in module.simphera_instance :
      name => flatten(instance.database_identifiers)
    }
    scenario_generation = {
      for name, instance in module.scenario_generation_instance :
      name => flatten(instance.database_identifiers)
    }
  }
}

output "database_endpoints" {
  description = "Endpoints of the databases from all instances."
  value = {
    simphera = {
      for name, instance in module.simphera_instance :
      name => flatten(instance.database_endpoints)
    }
    scenario_generation = {
      for name, instance in module.scenario_generation_instance :
      name => flatten(instance.database_endpoints)
    }
  }
}

output "s3_buckets" {
  description = "S3 buckets managed by terraform."
  value       = local.s3_buckets
}

output "eks_cluster_id" {
  description = "Amazon EKS Cluster Name"
  value       = module.eks.eks_cluster_id
}

output "opensearch_domain_endpoints" {
  description = "OpenSearch Domains endpoints of all the instances"
  value = {
    ivs = {
      for name, instance in module.ivs_instance :
      name => instance.opensearch_domain_endpoint
    }
    scenario_generation = {
      for name, instance in module.scenario_generation_instance :
      name => instance.opensearch_domain_endpoint
    }
  }
}


output "service_accounts" {
  description = "K8s service account names"
  value = {
    ivs = {
      s3_buckets = {
        for name, instance in module.ivs_instance :
        name => instance.ivs_buckets_service_account
      }
    }
    scenario_generation = {
      rag_core = {
        for name, instance in module.scenario_generation_instance :
        name => instance.ragcore_service_account
      }
      backend = {
        for name, instance in module.scenario_generation_instance :
        name => instance.backend_service_account
      }
    }
  }
}

output "ivs_node_groups_roles" {
  value = merge(local.ivs_node_groups_roles, var.windows_execution_node.enable ? { winexecnode : module.eks.node_groups[0]["winexecnodes"].nodegroup_role_id } : {})
}
