variable "location" {
  description = "Region where this service is deployed"
    type        = string
    default = "canadacentral"
}

variable "resource_group_name" {
  description = "Name of the resource group where the storage account will be deployed."
    type        = string
    default = "rg-cc-shared-storage"
}

variable "storage_account_name" {
  description = "Name of the storage account. Must be globally unique, 3-24 chars, lowercase letters and numbers only."
    type        = string
    default = "devsocketccsharedsa"
}

variable "account_tier" {
  description = "Storage account tier name, Standard for general purpose and premium for high performance"
    type        = string
    default = "Standard"
}

variable "account_replication_type" {
  description = "Replication Type. use LRS for dev. allowed are LRS, GRS, ZRS, GZRS, RA-GZRS"
    type        = string
    default = "LRS"
}

variable "account_kind" {
  description = "Storage account kind. StandardV2 is recommended for general purposes."
    type        = string
    default = "StorageV2"
}

variable "access_tier" {
  description = "Access tier for storage blob. Hot for frequently access data, cool for infrequent."
    type        = string
    default = "Hot"
}

# Security
variable "https_traffic_only_enabled" {
  description = "Enforce Https traffic only."
    type        = bool
    default = true
}

variable "min_tls_version" {
  description = "Minimum TLS version. TLS1.2 is the current recommended version."
    type        = string
    default = "TLS1_2"
}

variable "public_network_access_enabled" {
  description = "Allow public network access. True for basic demo, use private endpoint for security."
    type        = bool
    default = true
}

variable "allow_nested_items_to_be_public" {
  description = "Allow blob public access. disabled by default - blobs shouldn't be allowed to access publicly"
    type        = bool
    default = false
}

# Blob containers
variable "containers" {
  description = "Map of containers to create. Key is the container name, value is the access type"
    type        = map(string)
    default = {
        "app-data"  = "private"
        "app-logs"  = "private"
    }
     # Example:
  # containers = {
  #   "app-data"  = "private"
  #   "app-logs"  = "private"
  # }
}

# Life cycle policy
variable "enable_lifecycle_policy" {
  description = "Enable blob lifecycle management policy."
    type        = bool
    default = false
}

variable "lifecycle_deletion_after_days" {
  description = "Delete blob after these many days. applicable when enable_lifecycle_policy is set to true"
    type        = number
    default = 10
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID for diagnostics settings. leave to null to skip diagnostics"
    type        = string
    default = null
}

variable "tfstate_resource_group_name" {
  description = "Resource group of the Terraform state storage account."
  type        = string
}

variable "tfstate_storage_account_name" {
  description = "Name of the Terraform state storage account."
  type        = string
}

variable "tfstate_container_name" {
  description = "Blob container name for Terraform state."
  type        = string
  default     = "tfstate"
}

variable "tfstate_subscription_id" {
    description = "Storage subscription id of the remote state storage account. This is required when the connectivity subscription where the remote state lives is different from the default subscription of the landing zone deployment"
    type = string
}

# tags
variable "tags" {
  description = "tags applicable to all resource created by this module"
    type        = map(string)
     default = {
    environment = "shared"
    managed_by  = "terraform"
    project     = "devsocket-landing-zone"
    layer       = "app-platform"
  }
}
