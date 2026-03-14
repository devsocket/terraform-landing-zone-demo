variable "platform_sub_name" {
  description = "Name of the consolidated platform subscription. Associated to mg-management, mg-identity, mg-security."
  type        = string
  default     = "devsocket-platform-sub"
}

variable "connectivity_sub_name" {
  description = "Name of the connectivity subscription."
  type        = string
  default = "devsocket-connectivity-sub"
}

variable "lz_shared_sub_name" {
  description = "Name of the landing zone shared subscription."
  type        = string
  default = "devsocket-lz-shared-sub"
}

variable "lz_dev_sub_name" {
  description = "Name of the landing zone dev subscription."
  type        = string
    default = "devsocket-lz-dev-sub"
}

variable "lz_prod_sub_name" {
  description = "Name of the landing zone prod subscription."
  type        = string
    default = "devsocket-lz-prod-sub"
}