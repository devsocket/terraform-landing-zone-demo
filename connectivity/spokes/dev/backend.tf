terraform {
    required_version = ">=1.6.0"
    required_providers {
      azurerm = {
        source = "hashicorp/azurerm"
        version = ">=3.90.0, < 4.0.0"
      }
    }

    backend "azurerm" {
      resource_group_name = "rg-tfstate-devsocket"
      storage_account_name = "stgtfstatedevsocket"
      container_name = "connectivity/tfstate"
      key = "connectivity/spokes/dev.tfstate"
    }
}

provider "azurerm" {
    features {}
    # Set this env variable to the subscription where the spoke will be deployed, if different from the default subscription in your Azure CLI context
    # export ARM_SUBSCRIPTION_ID=""
}

# aliased provider - used only for hub-to-spoke peering resource, this must be created in the connectivity subscription
provider "azurerm" {
  alias = "connectivity"
  features {}
  subscription_id = var.connectivity_subscription_id
}