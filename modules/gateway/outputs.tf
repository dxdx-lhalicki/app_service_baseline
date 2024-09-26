# modules/gateway/outputs.tf

output "app_gateway_name" {
  description = "The name of the app gateway resource."
  value       = azurerm_application_gateway.app_gateway.name
}

output "app_gateway_fqdn" {
  description = "The FQDN of the App Gateway public IP."
  value       = azurerm_public_ip.app_gateway_public_ip.fqdn
}
