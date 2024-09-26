# modules/database/outputs.tf

output "sql_connection_string" {
  description = "The connection string to the sample database."
  value       = local.sql_connection_string
  sensitive   = true
}

output "sql_server_name" {
  description = "The name of the SQL Server."
  value       = azurerm_mssql_server.sql_server.name
}

output "sql_database_name" {
  description = "The name of the SQL Database."
  value       = azurerm_mssql_database.sql_database.name
}
