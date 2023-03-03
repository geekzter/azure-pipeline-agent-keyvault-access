data azuread_client_config current {}
data azurerm_subscription current {}

# Random resource suffix, this will prevent name collisions when creating resources in parallel
resource random_string suffix {
  length                       = 4
  upper                        = false
  lower                        = true
  numeric                      = false
  special                      = false
}

locals {
  devops_url                   = replace(var.devops_url,"/\\/$/","")
  owner_object_id              = var.owner_object_id != null && var.owner_object_id != "" ? lower(var.owner_object_id) : data.azuread_client_config.current.object_id
  suffix                       = var.resource_suffix != null && var.resource_suffix != "" ? lower(var.resource_suffix) : random_string.suffix.result
}

module service_principal {
  source                       = "./modules/service-principal"
  name                         = "${var.resource_prefix}-keyvault-service-connection-${terraform.workspace}-${local.suffix}"
  owner_object_id              = local.owner_object_id
}

module devops_project {
  source                       = "./modules/devops-project"
  name                         = "${var.resource_prefix}-keyvault-service-connection-${terraform.workspace}-${local.suffix}"
  service_principal_app_id     = module.service_principal.application_id
  service_principal_key        = module.service_principal.secret
  subscription_id              = data.azurerm_subscription.current.subscription_id
  subscription_name            = data.azurerm_subscription.current.display_name
  tenant_id                    = data.azuread_client_config.current.tenant_id
}