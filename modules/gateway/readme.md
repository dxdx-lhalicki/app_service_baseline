# Application Gateway Terraform Module

This Terraform module deploys an Azure Application Gateway with a Web Application Firewall (WAF) policy, managed identity, and a public IP address. It also configures log analytics and integrates with Key Vault for certificates.

## Usage

### Prerequisites

Before using this module, ensure that you have:
- A resource group in Azure.
- A virtual network and subnet for the application gateway.
- A Key Vault for managing secrets, including SSL certificates.

### Module Parameters

| Variable                       | Description                                           | Type     | Required | Sensitive |
| ------------------------------- | ----------------------------------------------------- | -------- | -------- | --------- |
| `resource_group_name`            | The name of the Azure resource group                  | `string` | Yes      | No        |
| `vnet_id`                        | The ID of the virtual network                         | `string` | Yes      | No        |
| `app_gateway_subnet_id`          | The ID of the subnet for the application gateway      | `string` | Yes      | No        |
| `web_app_default_site_hostname`  | The hostname of the application service               | `string` | Yes      | No        |
| `log_workspace_id`               | The ID of the Log Analytics workspace                 | `string` | Yes      | No        |
| `key_vault_id`                   | The ID of the Key Vault                               | `string` | Yes      | No        |
| `base_name`                      | Base name for Azure resources (6-12 chars)            | `string` | Yes      | No        |
| `location`                       | Location of the Azure resource group                  | `string` | Yes      | No        |
| `development_environment`        | Flag for cost-optimized development environments      | `bool`   | No       | No        |
| `availability_zones`             | List of availability zones                            | `list(string)` | No       | No        |
| `gateway_cert_secret_id`         | URI of the certificate secret in Key Vault            | `string` | Yes      | Yes       |
| `app_name`                       | Name of the existing App Service                      | `string` | Yes      | No        |

### Outputs

| Output                   | Description                                   | Sensitive |
| ------------------------- | --------------------------------------------- | --------- |
| `app_gateway_name`         | Name of the deployed Application Gateway      | No        |
| `app_gateway_fqdn`         | Fully qualified domain name of the App Gateway public IP | No        |

### Example Usage in Root Module

To use this module in your root module, reference it as shown below:

```hcl
module "app_gateway" {
  source                     = "./modules/gateway"
  resource_group_name         = "my-resource-group"
  vnet_id                     = "vnet-1234"
  app_gateway_subnet_id       = "subnet-5678"
  base_name                   = "myapp"
  location                    = "eastus"
  key_vault_id                = "keyvault-1234"
  log_workspace_id            = "log-1234"
  web_app_default_site_hostname = "myapp.azurewebsites.net"
  development_environment     = false
  availability_zones          = ["1", "2", "3"]
  gateway_cert_secret_id      = "https://mykeyvault.vault.azure.net/secrets/cert"
  app_name                    = "my-app-service"
}

output "app_gateway_name" {
  value = module.app_gateway.app_gateway_name
}
