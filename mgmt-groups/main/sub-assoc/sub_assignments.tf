locals {
    subs = {
        management = var.mgmt_sub_id
        identity = var.identity_sub_id
        security = var.security_sub_id
        connectivity = var.connectivity_sub_id
        lz_shared = var.lz_shared_sub_id
        lz_sandbox = var.lz_sandbox_sub_id
        lz_dev = var.lz_dev_sub_id
    }
}

resource "azurerm_management_group_subscription_association" "mgmt_sub" {
    management_group_id = data.azurerm_management_group.management.id
    subscription_id = local.subs.management
}

resource "azurerm_management_group_subscription_association" "identity_sub" {
    management_group_id = data.azurerm_management_group.identity.id
    subscription_id = local.subs.identity
}

resource "azurerm_management_group_subscription_association" "security_sub" {
    management_group_id = data.azurerm_management_group.security.id
    subscription_id = local.subs.security
}

resource "azurerm_management_group_subscription_association" "connectivity_sub" {
    management_group_id = data.azurerm_management_group.connectivity.id
    subscription_id = local.subs.connectivity
}

resource "azurerm_management_group_subscription_association" "lz_shared_sub" {
    management_group_id = data.azurerm_management_group.lz_shared.id
    subscription_id = local.subs.lz_shared
}

resource "azurerm_management_group_subscription_association" "lz_sandbox_sub" {
    management_group_id = data.azurerm_management_group.lz_sandbox.id
    subscription_id = local.subs.lz_sandbox
}

resource "azurerm_management_group_subscription_association" "lz_dev_sub" {
    management_group_id = data.azurerm_management_group.lz_dev.id
    subscription_id = local.subs.lz_dev
}