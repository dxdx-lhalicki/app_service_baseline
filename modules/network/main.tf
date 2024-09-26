# modles/network/main.tf
# Locals

locals {
  vnet_name              = "vnet-${var.base_name}"
}

# App Gateway Subnet NSG

resource "azurerm_network_security_group" "app_gateway_subnet_nsg" {
  name                = "nsg-appGatewaySubnet"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AppGw-In-Allow-ControlPlane"
    description                = "Allow inbound Control Plane"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["65200-65535"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    access                     = "Allow"
    priority                   = 100
    direction                  = "Inbound"
  }

  security_rule {
    name                       = "AppGw-In-Allow443-Internet"
    description                = "Allow ALL inbound web traffic on port 443"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["443"]
    source_address_prefix      = "Internet"
    destination_address_prefix = var.app_gateway_subnet_prefix[0]
    access                     = "Allow"
    priority                   = 110
    direction                  = "Inbound"
  }

  security_rule {
    name                       = "AppGw-In-Allow-LoadBalancer"
    description                = "Allow inbound traffic from Azure Load Balancer"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
    access                     = "Allow"
    priority                   = 120
    direction                  = "Inbound"
  }

  security_rule {
    name                       = "DenyAllInBound"
    description                = "Deny all inbound traffic"
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "*"
    destination_address_prefix = "*"
    access                     = "Deny"
    priority                   = 1000
    direction                  = "Inbound"
  }

  security_rule {
    name                       = "AppGw-Out-Allow-PrivateEndpoints"
    description                = "Allow outbound traffic to Private Endpoints subnet"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.app_gateway_subnet_prefix[0]
    destination_address_prefix = var.private_endpoints_subnet_prefix[0]
    access                     = "Allow"
    priority                   = 100
    direction                  = "Outbound"
  }

  security_rule {
    name                       = "AppGw-Out-Allow-AzureMonitor"
    description                = "Allow outbound traffic to Azure Monitor"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.app_gateway_subnet_prefix[0]
    destination_address_prefix = "AzureMonitor"
    access                     = "Allow"
    priority                   = 110
    direction                  = "Outbound"
  }
}

# App Service Subnet NSG

resource "azurerm_network_security_group" "app_service_subnet_nsg" {
  name                = "nsg-appServicesSubnet"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AppPlan-Out-Allow-PrivateEndpoints"
    description                = "Allow outbound traffic to Private Endpoints subnet"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["443"]
    source_address_prefix      = var.app_services_subnet_prefix[0]
    destination_address_prefix = var.private_endpoints_subnet_prefix[0]
    access                     = "Allow"
    priority                   = 100
    direction                  = "Outbound"
  }

  security_rule {
    name                       = "AppPlan-Out-Allow-AzureMonitor"
    description                = "Allow outbound traffic to Azure Monitor"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.app_services_subnet_prefix[0]
    destination_address_prefix = "AzureMonitor"
    access                     = "Allow"
    priority                   = 110
    direction                  = "Outbound"
  }
}

# Private Endpoints Subnet NSG

resource "azurerm_network_security_group" "private_endpoints_subnet_nsg" {
  name                = "nsg-privateEndpointsSubnet"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "PE-Out-Deny-All"
    description                = "Deny outbound traffic from Private Endpoints subnet"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.private_endpoints_subnet_prefix[0]
    destination_address_prefix = "*"
    access                     = "Deny"
    priority                   = 100
    direction                  = "Outbound"
  }
}

# Virtual Network

resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
}

# App Service Plan Subnet

resource "azurerm_subnet" "app_service_plan_subnet" {
  name                 = "snet-appServicePlan"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.app_services_subnet_prefix

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# subnet nsg association

resource "azurerm_subnet_network_security_group_association" "app_service_plan_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.app_service_plan_subnet.id
  network_security_group_id = azurerm_network_security_group.app_service_subnet_nsg.id
}

# App Gateway Subnet

resource "azurerm_subnet" "app_gateway_subnet" {
  name                                          = "snet-appGateway"
  resource_group_name                           = var.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  address_prefixes                              = var.app_gateway_subnet_prefix
  private_endpoint_network_policies             = "Enabled"
  private_link_service_network_policies_enabled = true
}

# subnet nsg association

resource "azurerm_subnet_network_security_group_association" "app_gateway_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.app_gateway_subnet.id
  network_security_group_id = azurerm_network_security_group.app_gateway_subnet_nsg.id
  
}

# Private Endpoints Subnet

resource "azurerm_subnet" "private_endpoints_subnet" {
  name                 = "snet-privateEndpoints"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.private_endpoints_subnet_prefix
}

# subnet nsg association

resource "azurerm_subnet_network_security_group_association" "private_endpoints_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.private_endpoints_subnet.id
  network_security_group_id = azurerm_network_security_group.private_endpoints_subnet_nsg.id
}
