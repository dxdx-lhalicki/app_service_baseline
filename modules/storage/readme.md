# Storage Account Terraform Module

This Terraform module deploys an Azure Storage Account with a private endpoint, and configures DNS settings for secure access to Blob storage.

## Usage

### Prerequisites

Before using this module, ensure that you have:
- A resource group in Azure.
- A virtual network and subnet for private endpoints.

### Module Parameters

| Variable                       | Description                                           | Type            | Required | Sensitive |
| ------------------------------- | ----------------------------------------------------- | --------------- | -------- | --------- |
| `resource_group_name`            | The name of the Azure resource group                  | `string`        | Yes      | No        |
| `vnet_id`                        | The ID of the virtual network                         | `string`        | Yes      | No        |
| `private_endpoints_subnet_id`    | The ID of the subnet for private endpoints            | `string`        | Yes      | No        |
| `base_name`                      | Base name for Azure resources (6-12 chars)            | `string`        | Yes      | No        |
| `location`                       | Location of the Azure resource group                  | `string`        | Yes      | No        |
| `storage_endpoint_suffix`        | DNS suffix for Azure Storage (default: `core.windows.net`) | `string`    | No       | No        |

### Outputs

| Output                               | Description                                   | Sensitive |
| ------------------------------------ | --------------------------------------------- | --------- |
| `storage_name`                       | Name of the deployed Storage Account          | No        |
| `storage_account_id`                 | ID of the Storage Account                     | No        |
| `storage_account_primary_blob_endpoint` | Primary Blob endpoint of the Storage Account  | No        |

### Example Usage in Root Module

To use this module in your root module, reference it as shown below:

```hcl
module "storage" {
  source                     = "./modules/storage"
  resource_group_name         = "my-resource-group"
  vnet_id                     = "vnet-1234"
  private_endpoints_subnet_id = "subnet-5678"
  base_name                   = "myapp"
  location                    = "eastus"
  storage_endpoint_suffix     = "core.windows.net"
}

output "storage_name" {
  value = module.storage.storage_name
}

output "storage_account_primary_blob_endpoint" {
  value = module.storage.storage_account_primary_blob_endpoint
}
