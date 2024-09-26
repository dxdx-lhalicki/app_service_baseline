variable "base_name" {
  description = "This is the base name for each Azure resource name (6-12 chars)"
  type        = string
}

variable "location" {
  description = "The resource group location"
  type        = string
}

variable "development_environment" {
  description = "Flag to indicate if this is a development environment"
  type        = bool
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

# Address prefixes

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "app_gateway_subnet_prefix" {
  description = "Address prefix for the App Gateway subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "app_services_subnet_prefix" {
  description = "Address prefix for the App Services subnet"
  type        = list(string)
  default     = ["10.0.0.0/24"]
}

variable "private_endpoints_subnet_prefix" {
  description = "Address prefix for the Private Endpoints subnet"
  type        = list(string)
  default     = ["10.0.2.0/27"]
}

variable "agents_subnet_prefix" {
  description = "Address prefix for the Agents subnet"
  type        = list(string)
  default     = ["10.0.2.32/27"]
}