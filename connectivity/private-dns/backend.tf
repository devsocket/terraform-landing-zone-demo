terraform {
    required_version = ">=1.6.0"
    required_providers {
      azurerm = {
        source = "hashicorp/azurerm"
        version = ">= 3.90.0, < 4.0.0"
      }
    }

    backend "azurerm" {
      resource_group_name = "rg-tfstate-devsocket"
      storage_account_name = "stgtfstatedevsocket"
      container_name = "tfstate"
      key = "connectivity/private-dns.tfstate"
    }
}

# Single provider — everything deploys into connectivity subscription
# DNS zones live in connectivity sub alongside hub VNet, and peering resources are created in connectivity subscription as well, so no need for aliased provider
provider "azurerm" {
    features {}
    # Set this env variable to the subscription where the private DNS zones will be deployed, if different from the default subscription in your Azure CLI context
    # export ARM_SUBSCRIPTION_ID="<devsocket-connectivity-sub-id>"
}