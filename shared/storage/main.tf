data "azurerm_client_config" "current" {}

data "terraform_remote_state" "log_analytics" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.tfstate_resource_group_name
    storage_account_name = var.tfstate_storage_account_name
    container_name       = var.tfstate_container_name
    key                  = "shared/monitoring/log-analytics.tfstate"
  }
}

module "storage_account" {
  source = "github.com/devsocket/terraform-common-modules/modules/app_platform/storage?ref=v0.2.0"

  resource_group_name       = var.resource_group_name
  location                  = var.location
  storage_account_name      = var.storage_account_name
  account_tier              = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind              = var.account_kind
  access_tier              = var.access_tier
  https_traffic_only        = var.https_traffic_only_enabled
  min_tls_version           = var.min_tls_version
  public_network_access_enabled = var.public_network_access_enabled
  allow_nested_items_to_be_public = var.allow_nested_items_to_be_public
  containers = var.containers
  enable_lifecycle_policy = var.enable_lifecycle_policy
  lifecycle_delete_after_days = var.lifecycle_delete_after_days

  # Wire Log Analytics from remote state
  log_analytics_workspace_id = data.terraform_remote_state.log_analytics.outputs.workspace_id
  tags = var.tags
}
