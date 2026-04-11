# Remote state - spoke dev
# Reads AKS subnet ID from connectivity layer

data "terraform_remote_state" "spoke_dev" {
    backend = "azurerm"

    config = {
        resource_group_name = var.tfstate_resource_group_name
        storage_account_name = var.tfstate_storage_account_name
        container_name = var.tfstate_storage_container_name
        subscription_id = var.tfstate_subscription_id
        key = "connectivity/spokes/dev.tfstate"
    }
}

# Remote state log analytics

data "terraform_remote_state" "log_analytics" {
    backend = "azurerm"

    config = {
        resource_group_name = var.tfstate_resource_group_name
        storage_account_name = var.tfstate_storage_account_name
        container_name = var.tfstate_storage_container_name
        subscription_id = var.tfstate_subscription_id
        key = "shared/monitoring/log-analytics.tfstate"
    }
}

# Remote state App Gateway
data "terraform_remote_state" "appgw" {
    backend = "azurerm"

    config = {
        resource_group_name = var.tfstate_resource_group_name
        storage_account_name = var.tfstate_storage_account_name
        container_name = var.tfstate_storage_container_name
        subscription_id = var.tfstate_subscription_id
        key = "apps/sample-app/dev/appgw.tfstate"
    }
}

# AKS cluster

module "aks" {
    source = "github.com/devsocket/terraform-common-modules//modules/app_platform/aks_cluster?ref=v1.0.0"
    resource_group_name = var.resource_group_name
    location = var.location
    cluster_name = var.cluster_name
    dns_prefix = var.dns_prefix
    kubernetes_version = var.kubernetes_version
    sku_tier = var.sku_tier

    node_pool_name = var.node_pool_name
    node_count = var.node_count
    vm_size = var.vm_size
    max_pods = var.max_pods
    os_disk_size_gb = var.os_disk_size_gb

    # AKS subnet - read from spoke remote state, not hardcoded
    vnet_subnet_id = data.terraform_remote_state.spoke_dev.outputs.aks_subnet_id

    network_plugin = var.network_plugin
    network_policy = var.network_policy
    service_cidr = var.service_cidr
    dns_service_ip = var.dns_service_ip

    # AGIC - app gateway id from apphw remote state, not hardcoded
    enable_agic = var.enable_agic
    app_gateway_id = data.terraform_remote_state.appgw.outputs.appgw_id

    enable_workload_identity = var.enable_workload_identity

    # log analytics workspace info - read from remote state, not hardcoded
    log_analytics_workspace_id = data.terraform_remote_state.log_analytics.outputs.workspace_id

    tags = var.tags

}

# AGIC role assignment
resource "azurerm_role_assignment" "agic" {
    count = var.enable_agic ? 1 : 0
    scope = data.terraform_remote_state.appgw.outputs.resource_group_id
    role_definition_name = "Contributor"
    principal_id = module.aks.agic_identity_object_id
}

# AKS cluster identity - VNet role assignment
# AKS cluster identity needs Network Contributor on the spoke VNet
# Without this, AKS cannot attach NICs and route pod traffic correctly
# This is a common deployment failure point — always assign this role

resource "azurerm_role_assignment" "aks_vnet_contributor" {
    scope = data.terraform_remote_state.spoke_dev.outputs.vnet_id
    role_definition_name = "Network Contributor"
    principal_id = module.aks.kubelet_identity_object_id
}