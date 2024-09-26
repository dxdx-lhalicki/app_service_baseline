# modules/storage/outputs.tf

output "storage_name" {
  description = "The name of the storage account."
  value       = azurerm_storage_account.storage.name
}

output "storage_account_id" {
  description = "The ID of the storage account."
  value       = azurerm_storage_account.storage.id
}

output "storage_account_primary_blob_endpoint" {
  description = "The primary Blob endpoint of the storage account."
  value       = azurerm_storage_account.storage.primary_blob_endpoint
}

