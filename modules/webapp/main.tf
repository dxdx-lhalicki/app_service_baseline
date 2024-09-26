# modules/webapp/main.tf

locals {
  app_name                          = "app-${var.base_name}"
  app_service_plan_name             = "asp-${local.app_name}${substr(md5(var.base_name), 0, 6)}"
  app_service_managed_identity_name = "id-${local.app_name}"
  app_service_private_endpoint_name = "pep-${local.app_name}"
  app_insights_name                 = "appinsights-${local.app_name}"
  app_services_dns_zone_name        = "privatelink.azurewebsites.net"
  app_services_dns_group_name       = "${local.app_service_private_endpoint_name}lh"
}

# Managed Identity for App Service
resource "azurerm_user_assigned_identity" "app_service_managed_identity" {
  name                = local.app_service_managed_identity_name
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Role Assignments
resource "azurerm_role_assignment" "key_vault_secrets_user_role_assignment" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.app_service_managed_identity.principal_id
}

resource "azurerm_role_assignment" "blob_data_reader_role_assignment" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_user_assigned_identity.app_service_managed_identity.principal_id
}

# Application Insights
resource "azurerm_application_insights" "app_insights" {
  name                = local.app_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = var.log_analytics_workspace_id
}

resource "azurerm_service_plan" "service_plan" {
  name                = local.app_service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "B1"
}

# Create a web app for hosting the AI web app
resource "azurerm_linux_web_app" "web_app" {
  name                = local.app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.service_plan.id

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app_service_managed_identity.id]
  }

  # Configure the web app to use the latest
  site_config {
    always_on              = false
    vnet_route_all_enabled = true
    http2_enabled          = true
  }

  virtual_network_subnet_id       = var.app_services_subnet_id
  https_only                      = false
  key_vault_reference_identity_id = azurerm_user_assigned_identity.app_service_managed_identity.id

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"             = azurerm_application_insights.app_insights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = azurerm_application_insights.app_insights.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~2"
  }

  depends_on = [
    azurerm_role_assignment.key_vault_secrets_user_role_assignment,
    azurerm_role_assignment.blob_data_reader_role_assignment,
    azurerm_service_plan.service_plan
  ]
}

# Private Endpoint for Web App
resource "azurerm_private_endpoint" "app_service_private_endpoint" {
  name                = local.app_service_private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = local.app_service_private_endpoint_name
    private_connection_resource_id = azurerm_linux_web_app.web_app.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = local.app_services_dns_group_name
    private_dns_zone_ids = [
      azurerm_private_dns_zone.app_services_dns_zone.id
    ]
  }
}

# Private DNS Zone
resource "azurerm_private_dns_zone" "app_services_dns_zone" {
  name                = local.app_services_dns_zone_name
  resource_group_name = var.resource_group_name
}

# Virtual Network Link to Private DNS Zone
resource "azurerm_private_dns_zone_virtual_network_link" "app_services_dns_zone_link" {
  name                  = "${local.app_services_dns_zone_name}-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.app_services_dns_zone.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}

# Diagnostic Settings for App Service Plan
resource "azurerm_monitor_diagnostic_setting" "app_service_plan_diagnostic" {
  name               = "${azurerm_service_plan.service_plan.name}-diagnosticSettings"
  target_resource_id = azurerm_service_plan.service_plan.id

  log_analytics_workspace_id = var.log_analytics_workspace_id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Diagnostic Settings for Web App
resource "azurerm_monitor_diagnostic_setting" "web_app_diagnostic" {
  name               = "${azurerm_linux_web_app.web_app.name}-diagnosticSettings"
  target_resource_id = azurerm_linux_web_app.web_app.id

  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  enabled_log {
    category = "AppServiceAppLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
