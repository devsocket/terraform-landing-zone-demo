variable "location" {
    description = "Azure region for ACR"
    type = string
    default = "canadacentral"
}

variable "resource_group_name" {
    description = "Resource group for ACR"
    type = string
    default = "rg-shared-acr"
}

variable "acr_name" {
    description = "Name of the Azure container registry. Must be globally unique, lowercase alpha number, between 5-50 chars."
    type = string
    default = "devsocketacr"
}

variable "sku" {
    description = "Tier of ACR"
    type = string
    default = "Basic"
}

variable "admin_enabled" {
    description = "Enable Admin credentials on this registry"
    type = bool
    default = false
}

# ACR Pull Access
# These are wired up in a second pass after AKS is deployed
# Leave both at defaults until AKS kubelet identity is known.

variable "enable_aks_pull_access" {
    description = "Create AcrPull role assignment for AKS kubenet identity. Set to 'true' after AKS is deployed"
    type = bool
    default = false
}

variable "aks_kubelet_identity_object_id" {
    description = "Object ID of AKS kubelet managed identity. required when 'enable_aks_pull_access' is set 'true'"
    type = string
    default = null
}

variable "tags" {
    description = "Tags applied to all resources"
    type = map(string)
    default = {
        environment = "shared"
        managed_by = "terraform"
        project = "devsocket_landing_zone"
        layer = "app-platform"
    }
}