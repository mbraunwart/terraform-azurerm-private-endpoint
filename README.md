---
title: "Azure Private Endpoint"
author: "Matt Braunwart"
date: "2024-01-15"
tags: ["azure", "network", "vnet", "dns", "terraform", "infrastructure"]
summary: "Terraform module for creating Azure Private Endpoints with DNS records."
---

<!-- BEGIN_TF_DOCS -->
<!-- TOC -->
- [Azure Private Endpoints](#azure-private-endpoints)
  - [Purpose](#purpose)
    - [Key Capabilities](#key-capabilities)
  - [Implementation Details](#implementation-details)
    - [Core Features](#core-features)
    - [Best Practices](#best-practices)
  - [Usage Example](#usage-example)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Resources](#resources)
  - [Required Inputs](#required-inputs)
    - [ app\_name](#-app_name)
    - [ dns\_zone\_name](#-dns_zone_name)
    - [ dns\_zone\_resource\_group\_name](#-dns_zone_resource_group_name)
    - [ dns\_zone\_resource\_id](#-dns_zone_resource_id)
    - [ environment](#-environment)
    - [ location](#-location)
    - [ private\_endpoint\_name](#-private_endpoint_name)
    - [ resource\_group\_name](#-resource_group_name)
    - [ service\_connection](#-service_connection)
    - [ subnet\_name](#-subnet_name)
    - [ virtual\_network\_name](#-virtual_network_name)
    - [ vnet\_resource\_group\_name](#-vnet_resource_group_name)
  - [Optional Inputs](#optional-inputs)
    - [ address\_prefixes](#-address_prefixes)
    - [ create\_subnet](#-create_subnet)
    - [ log\_analytics\_workspace\_id](#-log_analytics_workspace_id)
    - [ subnet\_id](#-subnet_id)
    - [ tags](#-tags)
  - [Outputs](#outputs)
    - [ private\_dns\_a\_record](#-private_dns_a_record)
    - [ private\_endpoint](#-private_endpoint)

<!-- /TOC -->

# Azure Private Endpoints

## Purpose
This Terraform module is designed to create and manage **Azure Private Endpoints** for secure, private access to Azure services. It also manages corresponding Private DNS records, ensuring that consumers within your virtual network can resolve the endpoint’s private IP address.

### Key Capabilities
- **Private Endpoint Creation**: Automatically provisions a private endpoint for the specified Azure resource.
- **DNS Record Management**: Creates a corresponding A record in an existing Azure Private DNS zone to simplify name resolution.
- **Diagnostic Logging**: Exposes variables for sending logs and metrics to your Log Analytics workspace, with default categories for auditing and monitoring.
- **Tagging**: Merges user-defined tags with module-defined tags to ensure consistent resource labeling (e.g., `service=private-endpoint`).

## Implementation Details
- **Resource Group and VNet Data Sources**: The module retrieves existing information about your resource group and virtual network, ensuring alignment with your existing infrastructure.
- **Private Endpoint**: Configures a `azurerm_private_endpoint` with a private service connection and DNS zone group. The subnet must already exist, identified by `subnet_id`.
- **Private DNS A Record**: Maps the private endpoint’s IP address to a consistent, environment-specific name (e.g., `<app-name>-<env>`).

### Core Features
1. **Flexible DNS Integration**  
   Attach the private endpoint to an existing private DNS zone through a DNS zone group and create an `A` record for convenient name resolution.

2. **Logging and Monitoring**  
   Leverage Azure diagnostic settings to capture logs and metrics from private endpoint resources, routing them to your Log Analytics workspace (or other supported sinks) based on your operational requirements.

3. **Resource Tagging**  
   Apply consistent tagging across resources, enabling better cost tracking and resource grouping within Azure.

### Best Practices
- Use a well-defined naming convention for your private endpoints and DNS records to avoid collisions and confusion in large deployments.
- Ensure your subnet meets all Azure requirements for private endpoints (e.g., no overlapping address spaces).
- Restrict network security group (NSG) rules around the private endpoint’s subnet to allow only necessary traffic, thereby hardening security.
- Forward logs to a Log Analytics workspace or storage account for compliance and advanced monitoring.

## Usage Example

```hcl
module "private_endpoint" {
  source = "./path-to-this-module"

  resource_group_name           = "my-rg"
  location                      = "eastus"
  environment                   = "dev"
  vnet_resource_group_name      = "my-network-rg"
  virtual_network_name          = "my-vnet"
  dns_zone_name                 = "privatelink.azurewebsites.net"
  dns_zone_resource_group_name  = "my-dns-rg"
  dns_zone_resource_id          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-dns-rg/providers/Microsoft.Network/privateDnsZones/privatelink.azurewebsites.net"
  subnet_id                     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-network-rg/providers/Microsoft.Network/virtualNetworks/my-vnet/subnets/my-subnet"
  app_name                      = "my-app"
  private_endpoint_name         = "my-pe"

  service_connection = {
    name        = "my-pe-connection"
    resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-service-rg/providers/Microsoft.Web/sites/myapp"
    is_manual   = false
    subresource_names = ["sites"]
  }

  log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/my-logs-rg/providers/Microsoft.OperationalInsights/workspaces/my-law"

  tags = {
    environment = "dev"
    owner       = "my-team"
  }
}
```

## Requirements

The following requirements are needed by this module:

- <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm) (>= 4.12.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) (>= 4.12.0)

- <a name="provider_azurerm.shd"></a> [azurerm.shd](#provider_azurerm.shd) (>= 4.12.0)

## Resources

The following resources are used by this module:

- [azurerm_private_dns_a_record.fx_dns_a_record](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) (resource)
- [azurerm_private_endpoint.pe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_app_name"></a> [app_name](#input_app_name)

Description: Name of the application

Type: `string`

### <a name="input_dns_zone_name"></a> [dns_zone_name](#input_dns_zone_name)

Description: Name of the private DNS zone

Type: `string`

### <a name="input_dns_zone_resource_group_name"></a> [dns_zone_resource_group_name](#input_dns_zone_resource_group_name)

Description: Name of the resource group containing the private DNS zone

Type: `string`

### <a name="input_dns_zone_resource_id"></a> [dns_zone_resource_id](#input_dns_zone_resource_id)

Description: Resource ID of the private DNS zone

Type: `string`

### <a name="input_environment"></a> [environment](#input_environment)

Description: Environment for mandatory tagging

Type: `string`

### <a name="input_location"></a> [location](#input_location)

Description: Location of the resource group where private endpoint will be created

Type: `string`

### <a name="input_private_endpoint_name"></a> [private_endpoint_name](#input_private_endpoint_name)

Description: Name of the private endpoint

Type: `string`

### <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name)

Description: Name of the resource group where private endpoint will be created

Type: `string`

### <a name="input_service_connection"></a> [service_connection](#input_service_connection)

Description: Details of the private service connection

Type:

```hcl
object({
    name              = string
    resource_id       = string
    is_manual         = optional(bool, false)
    subresource_names = optional(list(string), ["sites"])
  })
```

### <a name="input_subnet_name"></a> [subnet_name](#input_subnet_name)

Description: Name of the subnet for the private endpoint

Type: `string`

### <a name="input_virtual_network_name"></a> [virtual_network_name](#input_virtual_network_name)

Description: Name of the virtual network for the private endpoint

Type: `string`

### <a name="input_vnet_resource_group_name"></a> [vnet_resource_group_name](#input_vnet_resource_group_name)

Description: Name of the resource group containing the virtual network

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_address_prefixes"></a> [address_prefixes](#input_address_prefixes)

Description: List of address prefixes for the subnet

Type: `list(string)`

Default: `[]`

### <a name="input_create_subnet"></a> [create_subnet](#input_create_subnet)

Description: Whether to create a new subnet for the private endpoint

Type: `bool`

Default: `false`

### <a name="input_log_analytics_workspace_id"></a> [log_analytics_workspace_id](#input_log_analytics_workspace_id)

Description: The ID of the Log Analytics workspace to send diagnostics data to

Type: `string`

Default: `""`

### <a name="input_subnet_id"></a> [subnet_id](#input_subnet_id)

Description: Provided ID of the subnet for the private endpoint

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input_tags)

Description: A mapping of tags to assign to the resources

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_private_dns_a_record"></a> [private_dns_a_record](#output_private_dns_a_record)

Description: The private DNS A record

### <a name="output_private_endpoint"></a> [private_endpoint](#output_private_endpoint)

Description: The private endpoint
<!-- END_TF_DOCS -->