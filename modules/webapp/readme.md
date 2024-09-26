# Web App Terraform Module

This Terraform module deploys an Azure Web App along with a managed identity, Application Insights, and private endpoint support. It also configures role assignments for secure access to storage and Key Vault.

## Usage

### Prerequisites

Before using this module, ensure that you have:
- A resource group in Azure.
- A virtual network and subnets for App Services and private endpoints.
- A Key Vault and Storage Account for secure access.

### Module Parameters

| Variable                       | Description                                           | Type            | Required | Sensitive |
| ------------------------------- | ----------------------------------------------------- | --------------- | -------- | --------- |
| `base_name`                      | Base name for the App Service Plan and Web App        | `string`        | Yes      | No        |
| `resource_group_name`            | The name of the Azure resource group                  | `string`        | Yes      | No        |
| `location`                       | Location of the App Service Plan and Web App          | `string`        | Yes      | No        |
| `key_vault_id`                   | The ID of the Key Vault                               | `string`        | Yes      | No        |
| `storage_account_id`             | The ID of the Storage Account                         | `string`        | Yes      | No        |
| `log_analytics_workspace_id`     | The ID of the Log Analytics Workspace                 | `string`        | Yes      | No        |
| `tags`                           | A map of tags to assign to resources                  | `map(string)`   | No       | No        |
| `app_services_subnet_id`         | The ID of the subnet for App Services                 | `string`        | Yes      | No        |
| `private_endpoints_subnet_id`    | The ID of the subnet for Private Endpoints            | `string`        | Yes      | No        |
| `vnet_id`                        | The ID of the virtual network                         | `string`        | Yes      | No        |

### Outputs

| Output                   | Description                                   | Sensitive |
| ------------------------- | --------------------------------------------- | --------- |
| `app_service_plan_name`    | Name of the deployed App Service Plan         | No        |
| `app_name`                 | Name of the deployed Web App                  | No        |
| `default_hostname`         | The default hostname of the Web App           | No        |

### Example Usage in Root Module

To use this module in your root module, reference it as shown below:

```hcl
module "web_app" {
  source                           = "./modules/webapp"
  base_name                        = "myapp"
  resource_group_name              = "my-resource-group"
  location                         = "eastus"
  key_vault_id                     = "keyvault-1234"
  storage_account_id               = "storage-5678"
  log_analytics_workspace_id       = "log-9876"
  app_services_subnet_id           = "subnet-1122"
  private_endpoints_subnet_id      = "subnet-3344"
  vnet_id                          = "vnet-5566"
}

output "app_name" {
  value = module.web_app.app_name
}

output "default_hostname" {
  value = module.web_app.default_hostname
}
