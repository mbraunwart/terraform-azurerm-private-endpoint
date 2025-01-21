# output "private_endpoint_id" {
#   description = "The ID of the Private Endpoint"
#   value       = azurerm_private_endpoint.pe.id
# }

# output "private_endpoint_ip" {
#   description = "The private IP address of the Private Endpoint"
#   value       = azurerm_private_endpoint.pe.private_service_connection[0].private_ip_address
# }

# output "private_dns_a_record_id" {
#   description = "The ID of the Private DNS A Record"
#   value       = azurerm_private_dns_a_record.name.id
# }

# output "private_dns_a_record_fqdn" {
#   description = "The FQDN of the DNS A Record"
#   value       = "${azurerm_private_dns_a_record.name.name}.${data.azurerm_private_dns_zone.z.name}"
# }

# output "subnet_id" {
#   description = "The ID of the subnet where the private endpoint is deployed"
#   value       = local.subnet_id
# }

output "private_endpoint" {
    description = "The private endpoint"
    value       = azurerm_private_endpoint.pe
}

output "private_dns_a_record" {
    description = "The private DNS A record"
    value       = azurerm_private_dns_a_record.name
}