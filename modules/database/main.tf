# modules/database/main.tf

locals {
  sql_server_name           = "msql-${var.base_name}"
  sql_sample_database_name  = "sqldb-adventureworks"
  sql_private_endpoint_name = "pep-${local.sql_server_name}"
  sql_dns_group_name        = "${local.sql_private_endpoint_name}lh"
  sql_dns_zone_name         = "privatelink.database.windows.net"
  sql_connection_string     = "Server=tcp:${local.sql_server_name}.database.windows.net,1433;Initial Catalog=${local.sql_sample_database_name};Persist Security Info=False;User ID=${var.sql_administrator_login};Password=${var.sql_administrator_login_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
}

# SQL Server
resource "azurerm_mssql_server" "sql_server" {
  name                         = local.sql_server_name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  version                      = "12.0"
  administrator_login          = var.sql_administrator_login
  administrator_login_password = var.sql_administrator_login_password

  tags = {
    displayName = local.sql_server_name
  }

  public_network_access_enabled = false
}

# SQL Database
resource "azurerm_mssql_database" "sql_database" {
  name      = local.sql_sample_database_name
  server_id = azurerm_mssql_server.sql_server.id
  collation = "SQL_Latin1_General_CP1_CI_AS"
  sku_name  = "Basic"

  max_size_gb = 1
  sample_name = "AdventureWorksLT"

  tags = {
    displayName = local.sql_sample_database_name
  }
}

# Private Endpoint for SQL Server
resource "azurerm_private_endpoint" "sql_private_endpoint" {
  name                = local.sql_private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = local.sql_private_endpoint_name
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = local.sql_dns_group_name
    private_dns_zone_ids = [
      azurerm_private_dns_zone.sql_dns_zone.id
    ]
  }
}

# Private DNS Zone for SQL Server
resource "azurerm_private_dns_zone" "sql_dns_zone" {
  name                = local.sql_dns_zone_name
  resource_group_name = var.resource_group_name
}

# Virtual Network Link to Private DNS Zone
resource "azurerm_private_dns_zone_virtual_network_link" "sql_dns_zone_link" {
  name                  = "${local.sql_dns_zone_name}-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns_zone.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}
