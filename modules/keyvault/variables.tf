#modules/keyvault/variables.tf

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "vnet_id" {
  description = "The name of the virtual network"
  type        = string
}

variable "private_endpoints_subnet_id" {
  description = "The name of the subnet for private endpoints"
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

variable "sql_connection_string" {
  description = "The SQL connection string"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "The tenant ID for Key Vault"
  type        = string
}

variable "key_vault_dns_suffix" {
  description = "Key Vault DNS suffix (e.g., vaultcore.azure.net)"
  type        = string
  default     = "vaultcore.azure.net"
}
