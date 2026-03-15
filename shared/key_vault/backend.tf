terraform {
    required_version = ">=1.6.0"
    
    required_providers {
        azurerm = {
        source  = "hashicorp/azurerm"
        version = ">= 3.90.0, < 4.0.0"
        }
    }

  backend "azurerm" {
    resource_group_name  = "rg-tfstate-devsocket"
    storage_account_name = "stgtfstatedevsocket"
    container_name       = "tfstate"
    key = "shared/key-vault.tfstate"
  }
}

# Key Vault deploys into the shared subscription
provider "azurerm" {
  features {
    key_vault {
      # Allows terraform destroy to work cleanly on soft-deleted vaults
      # Without this, destroy leaves vault in soft-deleted state
      # and re-apply would fail trying to recreate a name that still exists
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
  # export ARM_SUBSCRIPTION_ID="<devsocket-lz-shared-sub-id>"
}