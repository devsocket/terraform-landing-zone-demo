variable "connectivity_subscription_id" {
    description = "Subscription ID of the connectivity subscription"
    type = string
    #Never hardcode Subscription IDs
}

variable "location" {
    description = "Azure region for spoke resources"
    type = string
    default = "canadacentral"
}

variable "resource_group_name" {
    description = "resource group name for spoke Vnet and resources"
    type = string
    default = "rg-devsocket-cc-spoke-dev"
}

variable "vnet_name" {
    description = "Dev vnet name"
    type = string
    default = "vnet-devsocket-spoke-dev"
}

variable "vnet_address_space" {
    description = "dev spoke vnet address space"
    type = list(string)
    default = ["10.1.0.0/16"]
}

# Subnets 
variable "aks_subnet_name" {
    description = "Aks node pool subnet name"
    type = string
    default = "snet-aks"
}

variable "aks_subnet_cidr" {
    description = "CIDR for aks subnet pool"
    type = string
    default = "10.1.0.0/22"
}

variable "appgw_subnet_name" {
    description = "Application Gateway subnet name"
    type  = string
    default = "snet-appgw"
}
variable "appgw_subnet_cidr" {
    description = "CIDR for Application Gateway subnet"
    type = string
    default = "10.1.4.0/24"
}
variable "private_endpoints_subnet_name" {
    description = "Subnet name of private endpoints"
    type = string
    default = "snet-privateendpoints"
}
variable "private_endpoints_subnet_cidr" {
    description = "CIDR of private endpoints"
    type = string
    default = "10.1.5.0/27"
}
# Route Table
variable "route_table_name" {
    description = "Name of the routing table attached to the spoke vnet"
    type = string
    default = "rt-devsocket-spoke-dev"
}

variable "disable_bgp_route_propogation" {
    description = "Disable BGP route propogation. Set true when routing through firewall"
    type = bool
    default = false
}

# Remote State
variable "tfstate_resource_group_name" {
    description = "Resource group name of the remote state storage account"
    type = string
    # fill from boot strapping output
}

variable "tfstate_storage_account_name" {
    description = "Storage account name of remote state storage account generated during boot strap phase"
    type = string
    # fill from bootstrap output
}

variable "tfstate_container_name" {
    description = "Storage container name of the remote state storage account"
    type = string
    default = "tfstate"
    #fill from bootstrap output
}

variable "tfstate_subscription_id" {
    description = "Storage subscription id of the remote state storage account. This is required when the connectivity subscription where the remote state lives is different from the default subscription of the landing zone deployment"
    type = string
}

# Tags
variable "tags" {
    description = "Tags applied to all resources in this deployment"
    type = map(string)
    default = {
        environment = "dev"
        managed_by = "terraform"
        project = "devsocket-landing-zone"
        layer = "spoke-network"
    }
}

