# modules/keyvault/main.tf

locals {
  key_vault_name                  = "lhtctkv1-${var.base_name}"
  key_vault_private_endpoint_name = "pep-${local.key_vault_name}"
  key_vault_dns_group_name        = "${local.key_vault_private_endpoint_name}lh"
  key_vault_dns_zone_name         = "privatelink.${var.key_vault_dns_suffix}"
}

# Key Vault
resource "azurerm_key_vault" "key_vault" {
  name                      = local.key_vault_name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  tenant_id                 = var.tenant_id
  purge_protection_enabled  = true
  enable_rbac_authorization = true
  sku_name                  = "standard"

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices" # Required for AppGW communication

    ip_rules = [
      "31.10.156.100"
    ]
  }

  # Access policies are not needed since RBAC is enabled
}

# Key Vault certificate for App Gateway Listener Certificate

resource "azurerm_key_vault_certificate" "gateway_public_cert" {
  name         = "generated-cert"
  key_vault_id = azurerm_key_vault.key_vault.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      # Server Authentication = 1.3.6.1.5.5.7.3.1
      # Client Authentication = 1.3.6.1.5.5.7.3.2
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject_alternative_names {
        dns_names = ["internal.contoso.com", "domain.hello.world"]
      }

      subject            = "CN=hello-world"
      validity_in_months = 12
    }
  }
}

# Key Vault Secret for SQL Connection String
resource "azurerm_key_vault_secret" "sql_connection_string_secret" {
  name         = "adWorksConnString"
  value        = var.sql_connection_string
  key_vault_id = azurerm_key_vault.key_vault.id
}

# Private Endpoint for Key Vault
resource "azurerm_private_endpoint" "key_vault_private_endpoint" {
  name                = local.key_vault_private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = local.key_vault_private_endpoint_name
    private_connection_resource_id = azurerm_key_vault.key_vault.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = local.key_vault_dns_group_name
    private_dns_zone_ids = [
      azurerm_private_dns_zone.key_vault_dns_zone.id
    ]
  }
}

# Private DNS Zone for Key Vault
resource "azurerm_private_dns_zone" "key_vault_dns_zone" {
  name                = local.key_vault_dns_zone_name
  resource_group_name = var.resource_group_name
}

# Virtual Network Link to Private DNS Zone
resource "azurerm_private_dns_zone_virtual_network_link" "key_vault_dns_zone_link" {
  name                  = "${local.key_vault_dns_zone_name}-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault_dns_zone.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}

