output "vnet_id" {
    description = "Resource ID of the Spoke Vnet."
    value = module.spoke_vnet.vnet_id
}

output "vnet_name" {
    description = "Name of spoke Vnet"
    value = module.spoke_vnet.vnet_name
}

output "vnet_address_space" {
    description = "Spoke Vnet Address space"
    value = module.spoke_vnet.vnet_address_space
}

# Subnet Ids

output "aks_subnet_id" {
    description = "Aks node pool subnet id"
    value = module.spoke_vnet.aks_subnet_id
}

output "aks_subnet_cidr" {
    description = "AKS node pool cidr range"
    value = module.spoke_vnet.aks_subnet_cidr
}

output "appgw_subnet_id" {
    description = "Application Gateway subnet id"
    value = module.spoke_vnet.appgw_subnet_id
}

output "appgw_subnet_cidr" {
    description = "Applicationo Gateway subnet cidr"
    value = module.spoke_vnet.gateway_subnet_cidr
}
output "private_endpoints_subnet_id" {
    description = "Private Endpoints subnet id"
    value = module.spoke_vnet.private_endpoints_subnet_id
}

output "private_endpoints_subnet_cidr" {
    description = "CIDR range of private endpoints subnet"
    value = module.spoke_vnet.private_endpoints_subnet_cidr
}

# Route Table
output "route_table_id" {
    description = "Spoke route table Id. Referenced when adding firewall rules later"
    value = module.spoke_vnet.route_table_id
}

#peering outputs
output "spoke_to_hub_peering_id" {
    description = "Spoke to Hub peering IDs" 
    value = module.spoke_vnet.spoke_to_hub_peering_id
}

output "hub_to_spoke_peering_id" {
    description = "Hub to Spoke peering IDs" 
    value = module.spoke_vnet.hub_to_spoke_peering_id
}

# Re-exporing Hub Values that downstream layers will need
# spoke remote state - they got both spoke and hub context from one place

output "hub_vnet_id" {
    description = "Hub VNet ID - Reexported from hub remote state for downstram convenice"
    value = data.terraform_remote_state.hub.outputs.vnet_id
}
output "hub_vnet_name" {
  description = "Hub VNet name — re-exported from hub remote state."
  value       = data.terraform_remote_state.hub.outputs.vnet_name
}

output "hub_resource_group_name" {
  description = "Hub resource group — re-exported from hub remote state."
  value       = data.terraform_remote_state.hub.outputs.resource_group_name
}
