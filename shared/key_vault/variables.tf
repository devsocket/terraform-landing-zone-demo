variable "location" {
  description = "Azure region for Key Vault."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Resource group for Key Vault."
  type        = string
  default     = "rg-shared-keyvault"
}

variable "key_vault_name" {
  description = "Name of the Key Vault. Must be globally unique, 3-24 chars, alphanumeric and hyphens."
  type        = string
  default     = "devsocket-kv"
}

variable "sku_name" {
  description = "Key Vault SKU."
  type        = string
  default     = "standard"
}

variable "soft_delete_retention_days" {
  description = "Soft delete retention in days. Minimum 7 for demo destroy compatibility."
  type        = number
  default     = 7
}

variable "purge_protection_enabled" {
  description = "Enable purge protection. Keep false for demo — blocks clean destroy if enabled."
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Allow public network access. True for Basic demo, false when private endpoint is added."
  type        = bool
  default     = true
}

# ── Role Assignments ──────────────────────────────────────────────────────────
# Empty by default — populated after AKS workload identity is known
# Add entries here in second pass after AKS deployment

variable "role_assignments" {
  description = "RBAC role assignments on the Key Vault. Populate after AKS workload identity is deployed."
  type = map(object({
    role         = string
    principal_id = string
  }))
  default = {}
}

# ── Remote State ──────────────────────────────────────────────────────────────
# Used to read Log Analytics workspace ID from shared/monitoring state

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

# ── Tags ──────────────────────────────────────────────────────────────────────

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default = {
    environment = "shared"
    managed_by  = "terraform"
    project     = "devsocket-landing-zone"
    layer       = "app-platform"
  }
}