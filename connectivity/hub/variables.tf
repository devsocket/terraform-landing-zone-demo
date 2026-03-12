variable "location" {
    type = string
    description = "Azure region where the hub virtual network will be deployed."
    default = "canadacentral"
}
variable "resource_group_name" {
    type = string
    description = "Name of the resource group where the hub virtual network will be deployed."
    default = "rg-cc-hub-connectivity"
}

variable "vnet_name" {
  type = string
    description = "Name of the hub virtual network."
    default = "vnet-cc-hub-devsocket"
}

variable "vnet_address_space" {
  type = list(string)
  description = "Address space for the hubVnet"
  default = ["10.0.0.0/16"]
}

variable "management_subnet_name" {
  description = "Name of the management subnet"
  type = string
  default = "ManagementSubnet"
}

variable "management_subnet_cidr" {
  description = "Address prefix for the management subnet."
  type = string
  default = "10.0.1.0/24"
}

variable "enable_gateway_subnet" {
  description = "Whether to create a Gateway subnet for future VPN or ExpressRoute connectivity."
  type = bool
  default = false
}

variable "tags" {
  description = "Tags to apply to all resources in this module."
    type        = map(string)
    default = {
        environment = "connectivity"
        managed_by = "terraform"
        project = "devsocket-landing-zone"
        layer = "hub-network"
    }
}