#modules/gateway/variables.tf

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "vnet_id" {
  description = "The name of the virtual network"
  type        = string
}

variable "app_gateway_subnet_id" {
  description = "The name of the subnet for the application gateway"
  type        = string
}

variable "web_app_default_site_hostname" {
  description = "The default_site_hostname of the application service"
  type        = string
}

variable "log_workspace_id" {
  description = "The name of the Log Analytics workspace"
  type        = string
}

variable "key_vault_id" {
  description = "The id of the key vault"
  type        = string
}

variable "base_name" {
  description = "This is the base name for each Azure resource name (6-12 chars)"
  type        = string
}

variable "location" {
  description = "The resource group location"
  type        = string
}

variable "development_environment" {
  description = "Optional. When true will deploy a cost-optimized environment for development purposes."
  type        = bool
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "gateway_cert_secret_id" {
  description = "URI to the secret holding the certificate in Key Vault"
  type        = string
}

# Existing resource names

variable "app_name" {
  description = "Name of the existing App Service"
  type        = string
}

