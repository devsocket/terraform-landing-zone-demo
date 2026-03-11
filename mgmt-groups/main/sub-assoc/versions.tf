terraform {
    required_version = ">= 1.6.0"
    backend "azurerm" {
        resource_group_name = "devsocket-tfstate-rg"
        storage_account_name = "stlandingzonedemostate"
        container_name = "tfstate"
        key = "mgmt-groups/sub-assoc/terraform.tfstate"
    }
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "~>3.116"
        }
    }
}