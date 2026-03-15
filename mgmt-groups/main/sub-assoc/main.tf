# Look up each subscription by name
data "azurerm_subscription" "platform" {
  display_name = var.platform_sub_name
}

data "azurerm_subscription" "connectivity" {
  display_name = var.connectivity_sub_name
}

data "azurerm_subscription" "lz_shared" {
  display_name = var.lz_shared_sub_name
}

data "azurerm_subscription" "lz_dev" {
  display_name = var.lz_dev_sub_name
}

data "azurerm_subscription" "lz_prod" {
  display_name = var.lz_prod_sub_name
}

# Platform sub associated to three MGs — management, identity, security
# One subscription can be associated to multiple management groups
resource "azurerm_management_group_subscription_association" "platform_mgmt" {
  management_group_id = "/providers/Microsoft.Management/managementGroups/devsocket-management"
  subscription_id     = data.azurerm_subscription.platform.subscription_id
}

resource "azurerm_management_group_subscription_association" "platform_identity" {
  management_group_id = "/providers/Microsoft.Management/managementGroups/devsocket-identity"
  subscription_id     = data.azurerm_subscription.platform.subscription_id
}

resource "azurerm_management_group_subscription_association" "platform_security" {
  management_group_id = "/providers/Microsoft.Management/managementGroups/devsocket-security"
  subscription_id     = data.azurerm_subscription.platform.subscription_id
}

resource "azurerm_management_group_subscription_association" "connectivity" {
  management_group_id = "/providers/Microsoft.Management/managementGroups/devsocket-connectivity"
  subscription_id     = data.azurerm_subscription.connectivity.subscription_id
}

resource "azurerm_management_group_subscription_association" "lz_shared" {
  management_group_id = "/providers/Microsoft.Management/managementGroups/devsocket-shared"
  subscription_id     = data.azurerm_subscription.lz_shared.subscription_id
}

resource "azurerm_management_group_subscription_association" "lz_dev" {
  management_group_id = "/providers/Microsoft.Management/managementGroups/devsocket-dev"
  subscription_id     = data.azurerm_subscription.lz_dev.subscription_id
}

resource "azurerm_management_group_subscription_association" "lz_prod" {
  management_group_id = "/providers/Microsoft.Management/managementGroups/devsocket-prod"
  subscription_id     = data.azurerm_subscription.lz_prod.subscription_id
}