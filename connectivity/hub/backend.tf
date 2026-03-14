terraform {
    required_version = ">=1.6.0"
    required_providers {
      azurerm = {
        source = "hashicorp/azurerm"
        version = "~>3.116"
      }
    }

    backend "azurerm" {
      resource_group_name = "rg-tfstate-devsocket"
      storage_account_name = "stgtfstatedevsocket"
      container_name       = "connectivty/tfstate"
      key = "connectivity/hub.tfstate"
    }
}
    provider "azurerm" {
        features {
          
        }

    # Set this env variable to the subscription where the hub will be deployed, if different from the default subscription in your Azure CLI context
    # export ARM_SUBSCRIPTION_ID=""
}
