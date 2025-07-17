output "database_identifiers" {
  description = "Identifiers of the Scenario Generation and Keycloak databases created for this Scenario Generation instance."
  value       = [aws_db_instance.scenario_generation.identifier]
}

output "database_endpoints" {
  description = "Endpoints of the Scenario Generation and Keycloak databases created for this Scenario Generation instance."
  value       = [aws_db_instance.simphera.endpoint]
}
