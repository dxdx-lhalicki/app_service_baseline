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

variable "sql_administrator_login" {
  description = "The administrator username of the SQL server"
  type        = string
}

variable "sql_administrator_login_password" {
  description = "The administrator password of the SQL server."
  type        = string
  sensitive   = true
}