variable "location" {
  description = "Azure region for the Log Analytics workspace."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Resource group for the Log Analytics workspace."
  type        = string
  default     = "rg-management-monitoring"
}

variable "workspace_name" {
  description = "Log Analytics workspace name."
  type        = string
  default     = "law-management-devsocket"
}

variable "retention_in_days" {
  description = "Log retention in days."
  type        = number
  default     = 30
}

variable "enable_container_insights" {
  description = "Enable ContainerInsights solution."
  type        = bool
  default     = true
}

variable "enable_security_insights" {
  description = "Enable SecurityInsights solution."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default = {
    environment = "management"
    managed_by  = "terraform"
    project     = "devsocket-landing-zone"
    layer       = "shared-monitoring"
  }
}