output "acr_id" {
    description = "ACR resource ID. Referenced by AKS role assignment and diagnostic settings"
    value = module.acr.acr_id
}

output "acr_name" {
   description = "ACR name. referenced in CI/CD pipelines and Kubernetes image pull config."
   value = module.acr.acr_name 
}

output "login_server" {
    description = "ACR login server URL. Referenced by AKS and Kubernetes manifests for image pulls."
    value = module.acr.login_server
}

output "resource_group_name" {
    description = "Resource group where ACR is created."
    value = module.acr.resource_group_name
}