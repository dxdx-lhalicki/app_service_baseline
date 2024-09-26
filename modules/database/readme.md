# SQL Database Terraform Module

This Terraform module deploys a SQL Server with a sample database and private endpoint on Azure. It also configures a private DNS zone and links it to a virtual network.

## Usage

### Prerequisites

Before using this module, ensure that you have:
- A resource group in Azure.
- A virtual network and subnet for private endpoints.
- SQL administrator credentials for the SQL server.

### Module Parameters

| Variable                       | Description                                           | Type     | Required | Sensitive |
| ------------------------------- | ----------------------------------------------------- | -------- | -------- | --------- |
| `resource_group_name`            | The name of the Azure resource group                  | `string` | Yes      | No        |
| `vnet_id`                        | The ID of the virtual network                         | `string` | Yes      | No        |
| `private_endpoints_subnet_id`    | The ID of the subnet for private endpoints            | `string` | Yes      | No        |
| `base_name`                      | Base name for Azure resources (6-12 chars)            | `string` | Yes      | No        |
| `location`                       | Location of the Azure resource group                  | `string` | Yes      | No        |
| `sql_administrator_login`        | Administrator login for the SQL server                | `string` | Yes      | No        |
| `sql_administrator_login_password` | Administrator password for the SQL server             | `string` | Yes      | Yes       |

### Outputs

| Output                   | Description                                   | Sensitive |
| ------------------------- | --------------------------------------------- | --------- |
| `sql_connection_string`    | Connection string for the SQL database        | Yes       |
| `sql_server_name`          | Name of the deployed SQL Server               | No        |
| `sql_database_name`        | Name of the deployed SQL Database             | No        |

### Example Usage in Root Module

To use this module in your root module, reference it as shown below:

```hcl
module "sql_database" {
  source                     = "./modules/database"
  resource_group_name         = "my-resource-group"
  vnet_id                     = "vnet-1234"
  private_endpoints_subnet_id = "subnet-5678"
  base_name                   = "myapp"
  location                    = "eastus"
  sql_administrator_login     = "adminuser"
  sql_administrator_login_password = "supersecurepassword"
}

output "sql_connection_string" {
  value = module.sql_database.sql_connection_string
}
