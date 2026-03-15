
# Current Client Config

# Reads the tenant ID from the currently authenticated Azure session
# Works whether you're logged in via az login, service principal, or managed identity
# tenant_id is the only value we need from here — everything else comes from variables

data "azurerm_client_config" "current" {}

# Remote State — Log Analytics

# Reads workspace ID from shared monitoring layer
# Used to wire diagnostic settings without hardcoding the workspace resource ID

data "terraform_remote_state" "log_analytics" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.tfstate_resource_group_name
    storage_account_name = var.tfstate_storage_account_name
    container_name       = var.tfstate_container_name
    key                  = "shared/monitoring/log-analytics.tfstate"
  }
}

#Key Vault

module "key_vault" {
  source = "github.com/devsocket/terraform-common-modules/modules/app_platform/key_vault"

  resource_group_name           = var.resource_group_name
  location                      = var.location
  key_vault_name                = var.key_vault_name
  sku_name                      = var.sku_name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days    = var.soft_delete_retention_days
  purge_protection_enabled      = var.purge_protection_enabled
  public_network_access_enabled = var.public_network_access_enabled
  role_assignments              = var.role_assignments

  # Wire Log Analytics from remote state
  # Diagnostic settings activate automatically once this is populated
  log_analytics_workspace_id = data.terraform_remote_state.log_analytics.outputs.workspace_id

  tags = var.tags
}