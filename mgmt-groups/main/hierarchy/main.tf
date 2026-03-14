locals {
    org_prefix = "devsocket"
}

resource "azurerm_management_group" "platform" {
  display_name = "${local.org_prefix}-platform"
  name = "${local.org_prefix}-platform"
 # parent_management_group_id omitted => placed under Tenant Root Group
}

resource "azurerm_management_group" "landing_zone" {
  display_name = "${local.org_prefix}-landing-zones"
  name = "${local.org_prefix}-landing-zones"
 # parent_management_group_id omitted => placed under Tenant Root Group
}

resource "azurerm_management_group" "management" {
  display_name = "${local.org_prefix}-management"
  name = "${local.org_prefix}-management"
  parent_management_group_id = azurerm_management_group.platform.id #omitted => placed under Tenant Root Group
}

resource "azurerm_management_group" "identity" {
  display_name = "${local.org_prefix}-identity"
  name = "${local.org_prefix}-identity"
  parent_management_group_id = azurerm_management_group.platform.id #omitted => placed under Tenant Root Group
}

resource "azurerm_management_group" "security" {
  display_name = "${local.org_prefix}-security"
  name = "${local.org_prefix}-security"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "connectivity" {
  display_name = "${local.org_prefix}-connectivity"
  name = "${local.org_prefix}-connectivity"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "lz_shared" {
  display_name = "${local.org_prefix}-lz-shared"
  name = "${local.org_prefix}-lz-shared"
  parent_management_group_id = azurerm_management_group.landing_zone.id
}

resource "azurerm_management_group" "lz_prod" {
  display_name = "${local.org_prefix}-lz-prod"
  name = "${local.org_prefix}-lz-prod"
  parent_management_group_id = azurerm_management_group.landing_zone.id
}

resource "azurerm_management_group" "lz_dev" {
  display_name = "${local.org_prefix}-lz-dev"
  name = "${local.org_prefix}-lz-dev"
  parent_management_group_id = azurerm_management_group.landing_zone.id
}

output "management_group_ids" {
  value = {
    platform = azurerm_management_group.platform.id
    landing_zone = azurerm_management_group.landing_zone.id
    management = azurerm_management_group.management.id
    identity = azurerm_management_group.identity.id
    security = azurerm_management_group.security.id
    connectivity = azurerm_management_group.connectivity.id
    lz_shared = azurerm_management_group.lz_shared.id
    lz_prod = azurerm_management_group.lz_prod.id
    lz_dev = azurerm_management_group.lz_dev.id
  }
}