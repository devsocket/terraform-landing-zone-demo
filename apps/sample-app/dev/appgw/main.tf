# Remote state - dev spoke

# Reads appgw subnet id from spoke remote state, which is created in connectivity/spokes/main.tf
# This is how appgw module knows which subnet to deploy into, without hardcoding the subnet
data "terraform_remote_state" "spoke_dev" {
    backend = "azurerm"
    config = {
        resource_group_name  = var.tfstate_resource_group_name
        storage_account_name = var.tfstate_storage_account_name
        container_name       = var.tfstate_container_name
        key                  = "connectivity/spokes/dev.tfstate"
}
}

# Remote state - log analytics workspace
# reads log analytics workspace id and key from connectivity/log-analytics workspace, which is created in connectivity/log-analytics/main.tf
data "terraform_remote_state" "log_analytics" {
    backend = "azurerm"
    config = {
        resource_group_name  = var.tfstate_resource_group_name
        storage_account_name = var.tfstate_storage_account_name
        container_name       = var.tfstate_container_name
        key                  = "shared/monitoring/log-analytics.tfstate"
}
}

# App Gateway
module "appgw" {
    source = "github.com/devsocket/terraform-common-modules//modules/app_platform/app_gateway_waf_agic?ref=v1.0.0"
    resource_group_name = var.resource_group_name
    location = var.location
    appgw_name = var.app_gateway_name
    sku_name = var.sku_name
    sku_tier = var.sku_tier
    appgw_capacity = var.capacity
    frontend_port = var.frontend_port
    public_ip_name = var.public_ip_name
    waf_policy_name = var.waf_policy_name
    waf_policy_mode = var.waf_policy_mode
    waf_rule_set_version = var.waf_rule_set_version

    # App gateway subnet - read from spoke remote state, not hardcoded
    subnet_id = data.terraform_remote_state.spoke_dev.outputs.appgw_subnet_id

    # log analytics workspace info - read from remote state, not hardcoded
    log_analytics_workspace_id = data.terraform_remote_state.log_analytics.outputs.workspace_id

    tags = var.tags
}

