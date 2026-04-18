# resource group
variable "resource_group_name" {
  description = "Resource group of AKS deployment"
  type = string
  default = "rg-cc-aks-dev"
}

variable "location" {
    description = "Azure region for AKS deployment"
    type = string
    default = "canadacentral"
}

# Cluster
variable "cluster_name" {
    description ="Name of the AKS cluster"
    type = string
    default = "aks-cc-devsocket-dev"
}

variable "dns_prefix" {
    description = "DNS prefix for the AKS cluster FQDN"
    type = string
    default = "cc-devsocket-dev"
}

variable "kubernetes_version" {
    description = "Kubernetes version. Null to use the latest version"
    type = string
    default = null
}

variable "sku_tier" {
    description = "AKS sku tier, free for demo"
    type = string
    default = "Free"
}

# Node Pool

variable "node_pool_name" {
    description = "AKS node pool name"
    type = string
    default = "systempool"
}

variable "node_count" {
    description  = "Number of nodes to deploy"
    type = number
    default = 1
}

variable "vm_size" {
    description = "VM type to deploy in the node"
    type = string
    default = "standard_b2s_v2"
}

variable "os_disk_size_gb" {
    description = "OS disk size in GB"
    type = number
    default = 30
}

variable "max_pods" {
    description  = "Maximum number of pods per node"
    type = number
    default = 30 # assuming 1GB per pod
}

# Networking
variable "network_plugin" {
    description = "Network plugin, Azure CNI required for AGIC"
    type = string
    default = "azure"
}

variable "network_policy" {
    description = "Network policy engine"
    type = string
    default = "azure"
}

variable "service_cidr" {
    description = "CIDR for k8s services, must not overlap with vnet address spaces"
    type = string
    default = "172.16.0.0/16"
}

variable "dns_service_ip" {
    description = "IP for Kubernetes DNS service. Must be within Service cidr"
    type = string
    default = "172.16.0.10"
}

# AGIC
variable "enable_agic" {
    description = "Enable AGIC addon. requires APP gateway to be deployed first"
    type = bool
    default = true
}

# Workload Identity
variable "enable_workload_identity" {
    description = "Enable workload identity and OIDC issuer"
    type = bool
    default = true
}

# Remote state
variable "tfstate_resource_group_name" {
    description = "Resource group of the remote state storage account"
    type = string
}

variable "tfstate_storage_account_name" {
    description = "Storage account name where tfstate is stored"
    type = string
}

variable "tfstate_storage_container_name" {
    description = "Storage container name where the remote tfstate is stored"
    type = string
    default = "tfstate"
}

variable "tfstate_subscription_id" {
    description = "Storage subscription id of the remote state storage account. This is required when the connectivity subscription where the remote state lives is different from the default subscription of the landing zone deployment"
    type = string
}

#tags
variable "tags" {
    description = "Tags applied to all resources"
    type = map(string)
    default = {
       environment = "dev"
       managed_by = "terraform"
       project = "devsocket-landing-zone"
       layer = "app-platform"
       component = "aks" 
    }
}

