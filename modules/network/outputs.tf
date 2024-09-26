# Outputs

output "virtual_network_id" {
  description = "The id of the vnet"
  value       = azurerm_virtual_network.vnet.id
}

output "app_services_subnet_id" {
  description = "The id of the app service plan subnet."
  value       = azurerm_subnet.app_service_plan_subnet.id
}

output "app_gateway_subnet_id" {
  description = "The id of the app gateway subnet."
  value       = azurerm_subnet.app_gateway_subnet.id
}

output "private_endpoints_subnet_id" {
  description = "The id of the private endpoints subnet."
  value       = azurerm_subnet.private_endpoints_subnet.id
}
