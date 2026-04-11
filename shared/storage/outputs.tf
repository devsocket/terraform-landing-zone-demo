output "storage_account_id" {
  description = "Storage Account Resource ID. Referenced for role assignments and diagnostic settings"
  value       = module.storage_account.storage_account_id
}

output "storage_account_name" {
  description = "Storage Account name. Referenced in application config and CI/CD pipelines."
  value       = module.storage_account.storage_account_name
}

output "primary_blob_endpoint" {
  description = "Primary blob service endpoint. Referenced by applications and data pipelines."
  value       = module.storage_account.primary_blob_endpoint
}

output "primary_access_key" {
  description = "Primary access key(sensitiv).Store in key vault - never pass to app config directly."
    value       = module.storage_account.primary_access_key
    sensitive = true
}

output "primary_connection_string" {
  description = "Primary connection string (Sensitive). store in ket vault, never pass to app config directly"
  value = module.storage_account.primary_connection_string
  sensitive = true
}

output "resource_group_name" {
  description = "Resource group name where the storage account is deployed"
  value = module.storage_account.resource_group_name
}

output "container_ids" {
  description = "Map of container name to resource ID"
  value = module.storage_account.container_ids
}

output "container_names" {
  description = "List of container names created in the storage account. Referenced in application config and CI/CD pipelines."
  value = module.storage_account.container_names
}