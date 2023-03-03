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
  initial_suffix               = var.resource_suffix != null && var.resource_suffix != "" ? lower(var.resource_suffix) : random_string.suffix.result
  initial_tags                 = merge(
    {
      application              = var.application_name
      githubRepo               = "https://github.com/geekzter/azure-pipeline-agent-keyvault-access"
      owner                    = local.owner
      provisioner              = "terraform"
      provisionerClientId      = data.azuread_client_config.current.client_id
      provisionerObjectId      = data.azuread_client_config.current.object_id
      repository               = "azure-pipelines-container-agent"
      runId                    = var.run_id
      suffix                   = local.initial_suffix
      workspace                = terraform.workspace
    },
    var.tags
  )
  owner                        = var.application_owner != "" ? var.application_owner : local.owner_object_id
  owner_object_id              = var.owner_object_id != null && var.owner_object_id != "" ? lower(var.owner_object_id) : data.azuread_client_config.current.object_id
  suffix                       = azurerm_resource_group.rg.tags["suffix"] # Ignores updates to var.resource_suffix
  tags                         = azurerm_resource_group.rg.tags           # Ignores updates to var.resource_suffix
}

resource azurerm_resource_group rg {
  name                         = terraform.workspace == "default" ? "${var.resource_prefix}-keyvault-variable-group-${local.initial_suffix}" : "${var.resource_prefix}-${terraform.workspace}-keyvault-variable-group-${local.initial_suffix}"
  location                     = var.location

  tags                         = local.initial_tags

  lifecycle {
    ignore_changes             = [
      location,
      name,
      tags["suffix"]
    ]
  }  
}

module key_vault {
  source                       = "./modules/key-vault"
  location                     = var.location
  resource_group_name          = azurerm_resource_group.rg.name
  tags                         = local.tags
}

module service_principal {
  source                       = "./modules/service-principal"
  name                         = "${var.resource_prefix}-keyvault-service-connection-${terraform.workspace}-${local.suffix}"
  owner_object_id              = local.owner_object_id
}

module devops_project {
  source                       = "./modules/devops-project"
  key_vault_name               = module.key_vault.key_vault_name
  name                         = "keyvault-service-connection-${terraform.workspace}-${local.suffix}"
  service_principal_app_id     = module.service_principal.application_id
  service_principal_key        = module.service_principal.secret
  subscription_id              = data.azurerm_subscription.current.subscription_id
  subscription_name            = data.azurerm_subscription.current.display_name
  tenant_id                    = data.azuread_client_config.current.tenant_id
}