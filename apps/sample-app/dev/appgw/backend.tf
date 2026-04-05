terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = ">= 3.90.0, < 4.0.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-tfstate-devsocket"
    storage_account_name = "stgtfstatedevsocket"
    container_name       = "tfstate"
    key = "apps/sample-app/dev/appgw.tfstate"
  }
}

provider "azurerm" {
  features {
  }
    # export ARM_SUBSCRIPTION_ID="<devsocket-lz-dev-sub-id>"
}