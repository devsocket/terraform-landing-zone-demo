terraform {
    backend "azurerm" {
      resource_group_name = "devsocket-tfstate-rg"
      storage_account_name = "stlandingzonedemostate"
      container_name = "tfstate"
      key = "global/terraform.tfstate"
    }
}