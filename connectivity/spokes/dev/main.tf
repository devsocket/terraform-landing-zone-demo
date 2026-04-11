# Remote state - Hub
# Reads output from connectivity/hub/outputs.tf
# This is how spoke knows hub Vnet ID, name and rg
# Without hardcoding these values here

data "terraform_remote_state" "hub" {
    backend = "azurerm"

    config = {
        resource_group_name = var.tfstate_resource_group_name
        storage_account_name = var.tfstate_storage_account_name
        container_name = var.tfstate_container_name
        key = "connectivity/hub.tfstate"
    }
}

# Spoke Vnet
module "spoke_vnet" {
    source = "github.com/devsocket/terraform-common-modules//modules/connectivity/spoke_vnet?ref=v1.0.0"

    #Spoke Identity
    resource_group_name = var.resource_group_name
    location = var.location
    vnet_name = var.vnet_name
    vnet_address_space = var.vnet_address_space

    #Subnets
    aks_subnet_name = var.aks_subnet_name
    aks_subnet_cidr = var.aks_subnet_cidr
    appgw_subnet_name = var.appgw_subnet_name
    app_subnet_cidr = var.appgw_subnet_cidr
    private_endpoints_subnet_name = var.private_endpoints_subnet_name
    private_endpoints_subnet_cidr = var.private_endpoints_subnet_cidr

    #Hub values - read from remote state, not hardcoded
    hub_vnet_id = data.terraform_remote_state.hub.outputs.vnet_id
    hub_vnet_name = data.terraform_remote_state.hub.outputs.vnet_name
    hub_resource_group_name = data.terraform_remote_state.hub.outputs.resource_group_name

    # Route Table
    route_table_name = var.route_table_name
    disable_bgp_route_propogation = var.disable_bgp_route_propogation

    tags = var.tags

    # Tells the module provider to use the connectivity alias when creating spoke vnet resources, so that it goes through the hub subscription and not the default subscription of the landing zone
    providers = {
        azurerm = azurerm
        azurerm.connectivity = azurerm.connectivity
    }
}