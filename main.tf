resource "azurerm_resource_group" "app_service_baseline_rg" {
  name     = "${var.name}-rg"
  location = var.resource_group_location
}

resource "azurerm_log_analytics_workspace" "log_workspace" {
  name                = "${var.name}-law"
  location            = azurerm_resource_group.app_service_baseline_rg.location
  resource_group_name = azurerm_resource_group.app_service_baseline_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "network" {
  source = "./modules/network"

  base_name               = var.name
  location                = azurerm_resource_group.app_service_baseline_rg.location
  development_environment = true
  resource_group_name     = azurerm_resource_group.app_service_baseline_rg.name
}

module "storage" {
  source = "./modules/storage"

  base_name                   = var.storage_account_name
  location                    = azurerm_resource_group.app_service_baseline_rg.location
  vnet_id                     = module.network.virtual_network_id
  private_endpoints_subnet_id = module.network.private_endpoints_subnet_id
  resource_group_name         = azurerm_resource_group.app_service_baseline_rg.name

  depends_on = [module.network]
}

module "database" {
  source = "./modules/database"

  base_name                        = var.name
  location                         = azurerm_resource_group.app_service_baseline_rg.location
  resource_group_name              = azurerm_resource_group.app_service_baseline_rg.name
  sql_administrator_login          = var.administrator_login
  sql_administrator_login_password = var.administrator_login_password
  vnet_id                          = module.network.virtual_network_id
  private_endpoints_subnet_id      = module.network.private_endpoints_subnet_id

  depends_on = [module.network]
}

module "keyvault" {
  source = "./modules/keyvault"

  base_name                   = var.name
  location                    = azurerm_resource_group.app_service_baseline_rg.location
  resource_group_name         = azurerm_resource_group.app_service_baseline_rg.name
  tenant_id                   = var.tenant_id
  vnet_id                     = module.network.virtual_network_id
  private_endpoints_subnet_id = module.network.private_endpoints_subnet_id
  sql_connection_string       = module.database.sql_connection_string

  depends_on = [
    module.network,
    module.database
  ]
}

module "webapp" {
  source = "./modules/webapp"

  base_name                   = var.name
  location                    = azurerm_resource_group.app_service_baseline_rg.location
  resource_group_name         = azurerm_resource_group.app_service_baseline_rg.name
  key_vault_id                = module.keyvault.key_vault_id
  storage_account_id          = module.storage.storage_account_id
  log_analytics_workspace_id  = azurerm_log_analytics_workspace.log_workspace.id
  app_services_subnet_id      = module.network.app_services_subnet_id
  private_endpoints_subnet_id = module.network.private_endpoints_subnet_id
  vnet_id                     = module.network.virtual_network_id
}

module "gateway" {
  source = "./modules/gateway"

  base_name                     = var.name
  location                      = azurerm_resource_group.app_service_baseline_rg.location
  resource_group_name           = azurerm_resource_group.app_service_baseline_rg.name
  vnet_id                       = module.network.virtual_network_id
  app_gateway_subnet_id         = module.network.app_gateway_subnet_id
  web_app_default_site_hostname = module.webapp.default_hostname
  log_workspace_id              = azurerm_log_analytics_workspace.log_workspace.id
  key_vault_id                  = module.keyvault.key_vault_id
  app_name                      = module.webapp.app_name
  development_environment       = var.development_environment
  availability_zones            = var.development_environment ? [] : [1, 2, 3]
  gateway_cert_secret_id        = module.keyvault.gateway_cert_secret_id
}
