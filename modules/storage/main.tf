# modules/storage/main.tf

locals {
  storage_name                  = "st${var.base_name}"
  storage_sku_name              = "Standard_LRS"
  storage_private_endpoint_name = "pep-${local.storage_name}"
  storage_dns_group_name        = "${local.storage_private_endpoint_name}default"
  blob_storage_dns_zone_name    = "privatelink.blob.${var.storage_endpoint_suffix}"
}

# Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = local.storage_name
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"
  min_tls_version          = "TLS1_2"

  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = []
  }

  blob_properties {
    versioning_enabled  = false
    change_feed_enabled = false

    delete_retention_policy {
      days = 7
    }
  }
}

# Private Endpoint for Storage Account
resource "azurerm_private_endpoint" "storage_private_endpoint" {
  name                = local.storage_private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = local.storage_private_endpoint_name
    private_connection_resource_id = azurerm_storage_account.storage.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = local.storage_dns_group_name
    private_dns_zone_ids = [
      azurerm_private_dns_zone.blob_storage_dns_zone.id
    ]
  }
}

# Private DNS Zone for Blob Storage
resource "azurerm_private_dns_zone" "blob_storage_dns_zone" {
  name                = local.blob_storage_dns_zone_name
  resource_group_name = var.resource_group_name
}

# Virtual Network Link to Private DNS Zone
resource "azurerm_private_dns_zone_virtual_network_link" "blob_storage_dns_zone_link" {
  name                  = "${local.blob_storage_dns_zone_name}-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.blob_storage_dns_zone.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}

