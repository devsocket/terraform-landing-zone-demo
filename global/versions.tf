terraform {
    required_version = ">= 1.6.0"
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "~>3.116"
        }
        azuread = {
            source = "hashicorp/azuread"
            version = "~>3.8.0"
        }
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = "~>3.0.1"
        }
        helm = {
            source = "hashicorp/helm"
         version = "~>2.13"
        }
        random = {
            source = "hashicorp/random"
            version = "~>3.6"
        }
    }
}