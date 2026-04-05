
# Cluster
output "cluster_id" {
    description = "AKS cluster resource ID"
    value = module.aks.cluster_id
}

output "cluster_name" {
    description = "AKS cluster name. used in az aks get-credentials command"
    value = module.aks.cluster_name
}

output "resource_group_name" {
    description = "Resource group where the AKS cluster is deployed"
    value = module.aks.resource_group_name
}

output "node_resource_group_name" {
  description = "Resource group name where the nodes are deployed."
  value = module.aks.node_resource_group
}

# Identity
output "cluster_identity_principal_id" {
    description = "AKS cluster principal identity system id"
    value = module.aks.cluster_identity_principal_id
}

output "kubelet_identity_object_id" {
    description = "Kubelet identity object ID. Feed back to shared/acr and shared/key_vault for role assignments."
    value = module.aks.kubelet_identity_object_id
}

output "kubelet_identity_client_id" {
    description = "Kubelet identity client ID. Used in workload identity federation configuration"
    value = module.aks.kubelet_identity_client_id
}

# Wokrload identity
output "oidc_issuer_url" {
    description = "OIDC issue url for workload identity federation. Used when creating federated identity credentials for pods"
    value = module.aks.oidc_issuer_url
}


# AGIC
output "agic_identity_object_id" {
    description = "AGIC managed identity object id"
    value = module.aks.agic_identity_object_id
}

# connectino
output "get_credentials_command" {
    description = "RUN this command utility after deployment to configure kubectl."
    value = "az aks get-credentials --resource-group ${module.aks.resource_group_name} --name ${module.aks.cluster_name} --overwrite-existing"
}