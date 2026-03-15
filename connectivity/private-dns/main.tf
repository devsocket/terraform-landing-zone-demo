# Remote State - Hub
data "terraform_remote_state" "hub" {
    backend = "azurerm"
    config = {
        resource_group_name   = var.tfstate_resource_group_name
        storage_account_name  = var.tfstate_storage_account_name
        container_name        = var.tfstate_storage_container_name
        key                   = "connectivity/hub.tfstate"
    }
}

# Remote State - Spoke Dev
data "terraform_remote_state" "spoke_dev" {
    backend = "azurerm"
    config = {
        resource_group_name   = var.tfstate_resource_group_name
        storage_account_name  = var.tfstate_storage_account_name
        container_name        = var.tfstate_storage_container_name
        key                   = "connectivity/spokes/dev.tfstate"
    }
}

# Private DNS zones are deployed in the connectivity subscription, so we can pull the hub vnet details from the hub remote state and create the necessary private endpoint connections and virtual network links to the hub vnet from this module, without needing to set up an additional provider or deploy any resources in the spoke subscriptions

module "private_dns" {
    source = "github.com/devsocket/terraform-common-modules/modules/connectivity/private_dns"

    location = var.location
    resource_group_name = var.resource_group_name
    dns_zones = var.dns_zones

    #Hub Vnet details pulled from remote state to create necessary virtual network links and private endpoint connections from the private DNS zones to the hub vnet
    hub_vnet_id = data.terraform_remote_state.hub.outputs.hub_vnet_id
    hub_vnet_link_name = "vnetlink-hub"

    # Spoke Vnet details pulled from remote state to create virtual network links from the private DNS zones to the spoke vnets
    # Add more spokes here as needed - just need to add the spoke key and vnet id to the spoke_vnet_links map
    spoke_vnet_links = {
        "dev" = data.terraform_remote_state.spoke_dev.outputs.spoke_vnet_id
    }

    enable_auto_registration = false
    tags = var.tags
}