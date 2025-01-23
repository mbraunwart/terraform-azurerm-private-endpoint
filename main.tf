locals {

  diag_private_endpoint_logs = [
    "AuditEvent"
  ]

  diag_private_endpoint_metrics = [
    "AllMetrics"
  ]

  diag_dns_zone_logs = [
    "RecordSetLogs",
    "AuditLogs"
  ]
}

data "azurerm_resource_group" "vnet_rg" {
  name = var.vnet_resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = data.azurerm_resource_group.vnet_rg.name
}

data "azurerm_private_dns_zone" "dns_zone" {
  name                = var.dns_zone_name
  resource_group_name = var.dns_zone_resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  name                  = format("link-%s", data.azurerm_private_dns_zone.dns_zone.name)
  private_dns_zone_name = data.azurerm_private_dns_zone.dns_zone.name
  resource_group_name   = data.azurerm_resource_group.vnet_rg.name
  virtual_network_id    = data.azurerm_virtual_network.vnet.id
  registration_enabled  = false

  tags = merge(var.tags, { "service" = "private-dns-zone-vnet-link" })
}

resource "azurerm_private_dns_a_record" "fx_dns_a_record" {
  name                = format("%s-%s", var.app_name, var.environment)
  zone_name           = var.dns_zone_name
  resource_group_name = data.azurerm_resource_group.vnet_rg.name
  records             = [azurerm_private_endpoint.pe.private_service_connection.0.private_ip_address]
  ttl                 = 300

  tags = merge(var.tags, { "service" = "private-dns-a-record" })
}

resource "azurerm_private_endpoint" "pe" {
  name                = var.private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_dns_zone_group {
    name                 = "link"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.zone.id]
  }

  private_service_connection {
    name                           = var.service_connection.name
    private_connection_resource_id = var.service_connection.resource_id
    is_manual_connection           = var.service_connection.is_manual
    subresource_names              = var.service_connection.subresource_names
  }

  tags = merge(var.tags, { "service" = "private-endpoint" })
}
