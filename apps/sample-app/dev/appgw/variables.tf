variable "location" {
    description = "Azure region for App Gateway resources"
    type = string
    default = "canadacentral"
}

variable "resource_group_name" {
    description = "resource group name for the App gateway"
    type = string
    default = "rg-cc-appgw-dev"
}

# Public IP
variable "public_ip_name" {
    description = "name of the public IP for App gateway frontend"
    type = string
    default = "pip-cc-appgw-dev"
}

# WAF Policy
variable "waf_policy_name" {
    description = "Waf policy name"
    type = string 
    default = "waf-policy-cc-dev"
}

variable "waf_policy_mode" {
    description = "WAF policy mode"
    type = string
    default = "Detection"
}

variable "waf_rule_set_version" {
    description = "OWASP rule set version"
    type = string
    default = "3.2"
}

# App gateway

variable "app_gateway_name" {
    description = "App gateway Name"
    type = string
    default = "agw-cc-devsocket-dev"
}

variable "sku_name" {
    description = "APP gateway SKU name"
    type = string 
    default = "WAF_v2"
}

variable "sku_tier" {
    description = "App gateway Sku Tier"
    type = string
    default = "WAF_v2"
}

variable "capacity" {
    description = "App gateway capacity units, use 2 or more for HA"
    type = number
    default = 1
}

# Remote state
variable "tfstate_resource_group_name" {
    description = "Resource group of the terraform state storage account."
    type = string
}

variable "tfstate_storage_account_name" {
    description = "Name of the Terraform state storage account"
    type = string
}

variable "tfstate_container_name" {
    description = "Blob container name for terraform state"
    type = string
    default = "tfstate"
}

variable "tfstate_subscription_id" {
    description = "Storage subscription id of the remote state storage account. This is required when the connectivity subscription where the remote state lives is different from the default subscription of the landing zone deployment"
    type = string
}

# tags
variable "tags" {
    description = "tags applied to all resources"
    type = map(string)
    default = {
        environment = "dev"
        managed_by = "terraform"
        project = "devsocket-landing-zone"
        layer = "app-platform"
        component = "app-gateway"
    }

}