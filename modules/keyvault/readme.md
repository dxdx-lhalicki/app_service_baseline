# Key Vault Terraform Module

This Terraform module deploys an Azure Key Vault with a private endpoint, a certificate for the Application Gateway, and integrates DNS settings for secure access.

## Usage

### Prerequisites

Before using this module, ensure that you have:
- A resource group in Azure.
- A virtual network and subnet for private endpoints.
- Tenant ID for the Azure Key Vault.

### Module Parameters

| Variable                       | Description                                           | Type     | Required | Sensitive |
| ------------------------------- | ----------------------------------------------------- | -------- | -------- | --------- |
| `resource_group_name`            | The name of the Azure resource group                  | `string` | Yes      | No        |
| `vnet_id`                        | The ID of the virtual network                         | `string` | Yes      | No        |
| `private_endpoints_subnet_id`    | The ID of the subnet for private endpoints            | `string` | Yes      | No        |
| `base_name`                      | Base name for Azure resources (6-12 chars)            | `string` | Yes      | No        |
| `location`                       | Location of the Azure resource group                  | `string` | Yes      | No        |
| `sql_connection_string`          | SQL connection string for secure database access      | `string` | No       | Yes       |
| `tenant_id`                      | Tenant ID for the Key Vault                           | `string` | Yes      | No        |
| `key_vault_dns_suffix`           | DNS suffix for the Key Vault (default: `vaultcore.azure.net`) | `string` | No       | No        |

### Outputs

| Output                   | Description                                   | Sensitive |
| ------------------------- | --------------------------------------------- | --------- |
| `key_vault_name`           | Name of the deployed Key Vault               | No        |
| `key_vault_id`             | ID of the deployed Key Vault                 | No        |
| `gateway_cert_secret_id`   | URI to the certificate secret in Key Vault   | Yes       |

### Example Usage in Root Module

To use this module in your root module, reference it as shown below:

```hcl
module "key_vault" {
  source                     = "./modules/keyvault"
  resource_group_name         = "my-resource-group"
  vnet_id                     = "vnet-1234"
  private_endpoints_subnet_id = "subnet-5678"
  base_name                   = "myapp"
  location                    = "eastus"
  tenant_id                   = "tenant-1234"
}

output "key_vault_name" {
  value = module.key_vault.key_vault_name
}

output "gateway_cert_secret_id" {
  value = module.key_vault.gateway_cert_secret_id
}
