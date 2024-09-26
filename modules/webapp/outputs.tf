# modules/webapp/outputs.tf

output "app_service_plan_name" {
  description = "The name of the app service plan."
  value       = azurerm_service_plan.service_plan.name
}

output "app_name" {
  description = "The name of the web app."
  value       = azurerm_linux_web_app.web_app.name
}

output "default_hostname" {
  description = "The default hostname of the web app."
  value       = azurerm_linux_web_app.web_app.default_hostname
  
}
