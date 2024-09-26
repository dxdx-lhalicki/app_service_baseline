# modules/keyvault/outputs.tf

output "key_vault_name" {
  description = "The name of the key vault account."
  value       = azurerm_key_vault.key_vault.name
}

output "key_vault_id" {
  description = "The id of the key vault account."
  value       = azurerm_key_vault.key_vault.id
}

output "gateway_cert_secret_id" {
  description = "Uri to the secret holding the cert."
  value       = azurerm_key_vault_certificate.gateway_public_cert.secret_id
}
