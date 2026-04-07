module "hub_vnet" {
  source = "git::https://github.com/devsocket/terraform-common-modules.git/modules/connectivity/hub_vnet?ref=v0.2.0"

  resource_group_name   = var.resource_group_name
  location              = var.location
  vnet_name            = var.vnet_name
  vnet_address_space   = var.vnet_address_space
  management_subnet_name = var.management_subnet_name
  management_subnet_cidr = var.management_subnet_cidr
  enable_gateway_subnet = var.enable_gateway_subnet
  tags                  = var.tags
}