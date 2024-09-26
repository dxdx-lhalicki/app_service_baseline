# Virtual Network Terraform Module

This Terraform module creates a virtual network (VNet) with separate subnets for App Gateway, App Services, Private Endpoints, and other services. It also configures network security groups (NSGs) for secure traffic management.

## Usage

### Prerequisites

Before using this module, ensure that you have:
- A resource group in Azure.
- Address prefixes for your virtual network and subnets.

### Module Parameters

| Variable                       | Description                                           | Type            | Required | Sensitive |
| ------------------------------- | ----------------------------------------------------- | --------------- | -------- | --------- |
| `base_name`                      | Base name for Azure resources (6-12 chars)            | `string`        | Yes      | No        |
| `location`                       | Location of the Azure resource group                  | `string`        | Yes      | No        |
| `development_environment`        | Flag to indicate if this is a development environment | `bool`          | No       | No        |
| `resource_group_name`            | The name of the Azure resource group                  | `string`        | Yes      | No        |
| `vnet_address_space`             | Address space for the virtual network                 | `list(string)`  | Yes      | No        |
| `app_gateway_subnet_prefix`      | Address prefix for the App Gateway subnet             | `list(string)`  | Yes      | No        |
| `app_services_subnet_prefix`     | Address prefix for the App Services subnet            | `list(string)`  | Yes      | No        |
| `private_endpoints_subnet_prefix`| Address prefix for the Private Endpoints subnet       | `list(string)`  | Yes      | No        |

### Outputs

| Output                       | Description                                   | Sensitive |
| ----------------------------- | --------------------------------------------- | --------- |
| `virtual_network_id`           | The ID of the virtual network                 | No        |
| `app_services_subnet_id`       | The ID of the App Services subnet             | No        |
| `app_gateway_subnet_id`        | The ID of the App Gateway subnet              | No        |
| `private_endpoints_subnet_id`  | The ID of the Private Endpoints subnet        | No        |

### Example Usage in Root Module

To use this module in your root module, reference it as shown below:

```hcl
module "vnet" {
  source                           = "./modules/vnet"
  base_name                        = "myapp"
  location                         = "eastus"
  resource_group_name              = "my-resource-group"
  vnet_address_space               = ["10.0.0.0/16"]
  app_gateway_subnet_prefix        = ["10.0.1.0/24"]
  app_services_subnet_prefix       = ["10.0.0.0/24"]
  private_endpoints_subnet_prefix  = ["10.0.2.0/27"]
}

output "virtual_network_id" {
  value = module.vnet.virtual_network_id
}

output "app_services_subnet_id" {
  value = module.vnet.app_services_subnet_id
}
