module "acr" {
      source = "github.com/devsocket/terraform-common-modules//modules/app_platform/acr"

      resource_group_name = var.resource_group_name
      location = var.location
      acr_name = var.acr_name
      sku = var.sku
      admin_enabled = var.admin_enabled
      enable_aks_pull_access = var.enable_aks_pull_access
      aks_kubelet_identity_object_id = var.aks_kubelet_identity_object_id
      tags = var.tags
}