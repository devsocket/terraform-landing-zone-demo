output "vnet_id" {
  description = "Hub Vnet resource ID. Referenced by spoke peering and private DNS modules."
  value = module.hub_vnet.vnet_id
}

output "vnet_name" {
  description = "Hub vnet name. referenced by spoke peering module"
  value = module.hub_vnet.vnet_name
}
output "vnet_address_space" {
  description = "Hub Vnet address space. Referenced by Spoke NSG and UDR rules."
  value = module.hub_vnet.vnet_address_space
}
output "resource_group_name" {
    description = "Name of the resource group where the hub vnet is deployed. Referenced by spoke peering and private DNS modules."
    value = module.hub_vnet.resource_group_name
}

output "management_subnet_id" {
  description = "Resource ID of the management subnet. Used for jumpbox NIC or Bastion association"
  value = module.hub_vnet.management_subnet_id
}

output "gateway_subnet_id" {
  description = "Gateway subnet resource ID. Null when enable_gatway_subnet is false"
  value = module.hub_vnet.gateway_subnet_id
}