variable "location" {
    description = "Azure region where the private DNS zones will be deployed."
    type = string
}

variable "resource_group_name" {
  description = "Resource group for private DNS zones. Lives in connectivity subscription"
  type = string
  default = "rg-connectivity-dns"
}

# DNS zones
variable "dns_zones" {
    description = "List of private DNS zones to create"
    type  = list(string)
    default = [
        "privatelink.azurecr.io",
        "privatelink.vaultcore.azure.net",
        "privatelink.blob.core.windows.net"
    ]
}

# Remote State
variable "tfstate_resource_group_name" {
    description = "Resource group of the terraform state storage account"
    type = string
}

variable "tfstate_storage_account_name" {
    description = "Storage account name of the terraform state storage account"
    type = string
}

variable "tfstate_storage_container_name" {
    description = "Blob Container name of teh terraform state storage account where the state is stored"
    type = string
}

# Tags
variable "tags" {
    description = "Tags applied to all resources in this deployment"
    type = map(string)
    default = {
        environment = "connectivity"
        managed_by = "terraform"
        project = "devsocket-landing-zone"
        layer = "private-dns"
    }
}
