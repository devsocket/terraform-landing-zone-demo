output "workspace_id" {
  description = "Resource ID — consumed by AKS, App Gateway, Key Vault diagnostic settings."
  value       = module.log_analytics.workspace_id
}

output "workspace_name" {
  description = "Workspace name."
  value       = module.log_analytics.workspace_name
}

output "workspace_customer_id" {
  description = "Customer ID for diagnostic settings and AKS OMS agent."
  value       = module.log_analytics.workspace_customer_id
}

output "primary_shared_key" {
  description = "Shared key for AKS OMS agent (sensitive)."
  value       = module.log_analytics.primary_shared_key
  sensitive   = true
}

output "resource_group_name" {
  description = "Resource group name."
  value       = module.log_analytics.resource_group_name
}