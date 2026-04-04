# Every private endpoint module needs to look up a zone ID by name. 
# The app layer — ACR, Key Vault, Storage — will read this state and use zone_ids["privatelink.azurecr.io"] style lookups. 
# Keep that consumer in mind reading these outputs.

# DNS zones
output "zone_ids" {
    description = "Map of DNS zone name to resource ID. key is zone name e.g., 'privatelink.azurerm.io' consumed by private endpoint moudles."
    value = module.private_dns.zone_ids
}

output "zone_names" {
    description = "Map of zone to confirmed zone name from azure"
    value = module.private_dns.zone_names
}

output "resource_group_name" {
    description = "Resource group where DNS zones are created."
    value = module.private_dns.resource_group_name
}

# VNet Links
output "hub_vnet_link_ids" {
    description = "Map of zone name to Hub Vnet link resource ID"
    value = module.private_dns.hub_vnet_link_ids
}

output "spoke_vnet_link_ids" {
    description = "Map of zone name tp Spoke Vnet link resource ID"
    value = module.private_dns.spoke_vnet_link_ids
}

# Convenience Lookups
# Pre-resolved zone IDs for the three zones we know exist
# Saves downstream callers from having to do map lookups inline
# These will error sometimes during plan phase when the zone was not yet created - intentional

output "acr_zone_id" {
    description = "Private DNS zone ID for ACR. Short cut for zone_ids[\"privatelink.azurecr.io\"]"
    value = module.private_dns.zone_ids["privatelink.azurecr.io"]
}

output "keyvault_zone_id" {
    description = "Private DNS zone ID for KeyVault. Shortcut for zone_ids[\"privatelink.vaultcore.azure.net\"]"
    value = module.private_dns.zone_ids["privatelink.vaultcore.azure.net"]
}

output "storage_zone_id" {
    description = "Private DNS zone ID for Storage account. Shortcut for zone_ids[\"privatelink.blob.core.windows.net\"]"
    value = module.private_dns.zone_ids["privatelink.blob.core.windows.net"]
}