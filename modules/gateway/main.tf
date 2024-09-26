# modules/gateway/main.tf

locals {
  app_gateway_name                  = "agw-${var.base_name}"
  app_gateway_managed_identity_name = "id-${local.app_gateway_name}"
  app_gateway_public_ip_name        = "pip-${var.base_name}"
  app_gateway_fqdn                  = "fe-${var.base_name}"
  waf_policy_name                   = "waf-${var.base_name}"
}

# Managed Identity for App Gateway
resource "azurerm_user_assigned_identity" "app_gateway_managed_identity" {
  name                = local.app_gateway_managed_identity_name
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Grant the App Gateway managed identity access to Key Vault
resource "azurerm_role_assignment" "app_gateway_key_vault_role_assignment" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.app_gateway_managed_identity.principal_id
  principal_type       = "ServicePrincipal"
}

# Public IP for App Gateway
resource "azurerm_public_ip" "app_gateway_public_ip" {
  name                    = local.app_gateway_public_ip_name
  location                = var.location
  resource_group_name     = var.resource_group_name
  allocation_method       = "Static"
  sku                     = "Standard"
  idle_timeout_in_minutes = 4
  domain_name_label       = local.app_gateway_fqdn
  zones                   = var.development_environment ? null : var.availability_zones
}

# WAF Policy
resource "azurerm_web_application_firewall_policy" "waf_policy" {
  name                = local.waf_policy_name
  location            = var.location
  resource_group_name = var.resource_group_name

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }

    managed_rule_set {
      type    = "Microsoft_BotManagerRuleSet"
      version = "0.1"
    }
  }

  policy_settings {
    file_upload_limit_in_mb = 10
    mode                    = "Prevention"
  }
}

# Application Gateway
resource "azurerm_application_gateway" "app_gateway" {
  name                = local.app_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app_gateway_managed_identity.id]
  }

  zones = var.development_environment ? null : var.availability_zones

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = var.app_gateway_subnet_id
  }

  frontend_port {
    name = "port-443"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "appGwPublicFrontendIp"
    public_ip_address_id = azurerm_public_ip.app_gateway_public_ip.id
  }

  ssl_certificate {
    name                = "${local.app_gateway_name}-ssl-certificate"
    key_vault_secret_id = var.gateway_cert_secret_id
  }

  http_listener {
    name                           = "WebAppListener"
    frontend_ip_configuration_name = "appGwPublicFrontendIp"
    frontend_port_name             = "port-443"
    protocol                       = "Https"
    ssl_certificate_name           = "${local.app_gateway_name}-ssl-certificate"
  }

  backend_address_pool {
    name = "pool-${var.app_name}"
    fqdns = [
      var.web_app_default_site_hostname
    ]
  }

  backend_http_settings {
    name                                = "WebAppBackendHttpSettings"
    port                                = 443
    protocol                            = "Https"
    cookie_based_affinity               = "Disabled"
    request_timeout                     = 20
    pick_host_name_from_backend_address = true
    probe_name                          = "probe-web${var.base_name}"
  }

  probe {
    name                                      = "probe-web${var.base_name}"
    protocol                                  = "Https"
    path                                      = "/favicon.ico"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true

    match {
      status_code = ["200-399", "401", "403"]
    }
  }

  request_routing_rule {
    name                       = "WebAppRoutingRule"
    rule_type                  = "Basic"
    priority                   = 100
    http_listener_name         = "WebAppListener"
    backend_address_pool_name  = "pool-${var.app_name}"
    backend_http_settings_name = "WebAppBackendHttpSettings"
  }

  firewall_policy_id = azurerm_web_application_firewall_policy.waf_policy.id

  autoscale_configuration {
    min_capacity = var.development_environment ? 2 : 3
    max_capacity = var.development_environment ? 3 : 5
  }

  enable_http2 = false

  depends_on = [
    azurerm_role_assignment.app_gateway_key_vault_role_assignment
  ]
}

# Diagnostic Settings for App Gateway
resource "azurerm_monitor_diagnostic_setting" "app_gateway_diag_settings" {
  name                       = "${azurerm_application_gateway.app_gateway.name}-diagnosticSettings"
  target_resource_id         = azurerm_application_gateway.app_gateway.id
  log_analytics_workspace_id = var.log_workspace_id

  enabled_log {
    category = "ApplicationGatewayAccessLog"
  }

  enabled_log {
    category = "ApplicationGatewayPerformanceLog"
  }

  enabled_log {
    category = "ApplicationGatewayFirewallLog"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
