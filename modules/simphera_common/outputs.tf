output "database_identifier" {
  description = "Identifier of the database from the SIMPHERA instance."
  value       = aws_db_instance.database.identifier
}

output "database_endpoint" {
  description = "Endpoint of the database from the SIMPHERA instance."
  value       = aws_db_instance.database.endpoint
}
