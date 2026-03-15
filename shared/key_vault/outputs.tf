
output "key_vault_id" {
  description = "Key Vault resource ID. Referenced for additional role assignments and diagnostic settings."
  value       = module.key_vault.key_vault_id
}

output "key_vault_name" {
  description = "Key Vault name. Referenced in application config and CI/CD pipelines."
  value       = module.key_vault.key_vault_name
}

output "key_vault_uri" {
  description = "Key Vault URI. Referenced by AKS workload identity and application secret fetch config."
  value       = module.key_vault.key_vault_uri
}

output "resource_group_name" {
  description = "Resource group where Key Vault was created."
  value       = module.key_vault.resource_group_name
}

output "tenant_id" {
  description = "Tenant ID the Key Vault is associated with. Referenced in workload identity configuration."
  value       = module.key_vault.tenant_id
}