variable "resource_group_name" {
  type        = string
  description = "Name of the resource group where private endpoint will be created"
}

variable "location" {
  type        = string
  description = "Location of the resource group where private endpoint will be created"
}

variable "environment" {
  type        = string
  description = "Environment for mandatory tagging"
}

variable "vnet_resource_group_name" {
  type        = string
  description = "Name of the resource group containing the virtual network"
}

variable "dns_zone_name" {
  type        = string
  description = "Name of the private DNS zone"
}

variable "dns_zone_resource_group_name" {
  type        = string
  description = "Name of the resource group containing the private DNS zone"
  default     = ""
}

variable "dns_zone_resource_id" {
  type        = string
  description = "Resource ID of the private DNS zone"
  default     = ""
}

variable "virtual_network_name" {
  type        = string
  description = "Name of the virtual network for the private endpoint"
}

variable "subnet_id" {
  type        = string
  description = "Provided ID of the subnet for the private endpoint"
  default     = null
}

variable "create_subnet" {
  type        = bool
  description = "Whether to create a new subnet for the private endpoint"
  default     = false
}

variable "address_prefixes" {
  type        = list(string)
  description = "List of address prefixes for the subnet"
  default     = []

  validation {
    condition     = length(var.address_prefixes) > 0 ? can([for prefix in var.address_prefixes : cidrhost(prefix, 0)]) : true
    error_message = "Address prefixes must be valid CIDR notation, e.g., '10.0.1.0/24'."
  }
}

variable "app_name" {
  type        = string
  description = "Name of the application"

  validation {
    condition     = length(var.app_name) >= 1 && length(var.app_name) <= 80
    error_message = "Application name must be between 1 and 80 characters long."
  }
}

variable "private_endpoint_name" {
  type        = string
  description = "Name of the private endpoint"

  validation {
    condition     = length(var.private_endpoint_name) >= 1 && length(var.private_endpoint_name) <= 80
    error_message = "Private endpoint name must be between 1 and 80 characters long."
  }
}

variable "service_connection" {
  type = object({
    name              = string
    resource_id       = string
    is_manual         = optional(bool, false)
    subresource_names = optional(list(string), ["sites"])
  })
  description = "Details of the private service connection"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "The ID of the Log Analytics workspace to send diagnostics data to"
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources"
  default     = {}
}
