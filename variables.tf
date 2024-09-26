
variable "name" {
  type        = string
  description = "The name of the resource"
}

variable "resource_group_location" {
  type        = string
  description = "The location of the resource group"
}

variable "administrator_login" {
  type        = string
  description = "The administrator username of the SQL server"
}

variable "administrator_login_password" {
  type        = string
  description = "The administrator password of the SQL server."
  sensitive   = true  
}

variable "custom_domain_name" {
  type        = string
  description = "The custom domain name for the application gateway"
}

variable "development_environment" {
  type        = bool
  description = "Optional. When true will deploy a cost-optimized environment for development purposes."
}

variable "storage_account_name" {
  type        = string
  description = "The name of the storage account"
}

variable "tenant_id" {
  type        = string
  description = "The tenant id of the Azure AD tenant"
}