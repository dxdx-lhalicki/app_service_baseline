variable "base_name" {
  description = "The base name for the App Service Plan and App Service"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location of the App Service Plan and App Service"
  type        = string
}

variable "key_vault_id" {
  description = "The ID of the Key Vault"
  type        = string
}

variable "storage_account_id" {
  description = "The ID of the Storage Account"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "app_services_subnet_id" {
  description = "The ID of the subnet for the App Services"
  type        = string
}

variable "private_endpoints_subnet_id" {
  description = "The ID of the subnet for the Private Endpoints"
  type        = string
}

variable "vnet_id" {
  description = "The ID of the virtual network"
  type        = string
}