# terraform-landing-zone-demo/apps/sample-app/dev/appgw/outputs.tf

output "app_gateway_id" {
  description = "App Gateway resource ID. Read by aks/ folder via remote state for AGIC add-on."
  value       = module.app_gateway.app_gateway_id
}

output "app_gateway_name" {
  description = "App Gateway name."
  value       = module.app_gateway.app_gateway_name
}

output "resource_group_name" {
  description = "App Gateway resource group name. Used for AGIC Contributor role assignment scope."
  value       = module.app_gateway.resource_group_name
}

output "resource_group_id" {
  description = "App Gateway resource group ID. Used as scope for AGIC Contributor role assignment."
  value       = module.app_gateway.resource_group_id
}

output "public_ip_address" {
  description = "Frontend public IP address. Point DNS A record here after deployment."
  value       = module.app_gateway.public_ip_address
}

output "waf_policy_id" {
  description = "WAF policy resource ID."
  value       = module.app_gateway.waf_policy_id
}