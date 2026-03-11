#Set your Organization prefix once here
locals {
    org_prefix = "devsocket"
}

# Data Sources for MGs (Resolve IDs by name)
data "azurerm_management_group" "management" {
    name = "${local.org_prefix}-management"
}

data "azurerm_management_group" "identity" {
    name = "${local.org_prefix}-identity"
}

data "azurerm_management_group" "security" {
    name = "${local.org_prefix}-security"
}

data "azurerm_management_group" "connectivity" {
    name = "${local.org_prefix}-connectivity"
}

data "azurerm_management_group" "lz_shared" {
    name = "${local.org_prefix}-lz_shared"
}

data "azurerm_management_group" "lz_sandbox" {
    name = "${local.org_prefix}-lz_sandbox"
}

data "azurerm_management_group" "lz_dev" {
    name = "${local.org_prefix}-lz_dev"
}