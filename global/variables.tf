variable "environment" {
    type = string
    description = "Environment name (mgmt|dev|test|prod)"
}

variable "region" {
    type = string
    default = "canadacentral"
    description = "Azure region for resource deployment"
}

variable "subscription_id" {
  type = string
  description = "Azure Subscription ID for resource deployment"
}
