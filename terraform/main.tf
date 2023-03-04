data azuread_client_config current {}
data azurerm_subscription current {}

data http terraform_ip_address {
# Get public IP address of the machine running this terraform template
  url                          = "https://ipinfo.io/ip"
}
data http terraform_ip_prefix {
# Get public IP prefix of the machine running this terraform template
  url                          = "https://stat.ripe.net/data/network-info/data.json?resource=${chomp(data.http.terraform_ip_address.response_body)}"
}

# Random resource suffix, this will prevent name collisions when creating resources in parallel
resource random_string suffix {
  length                       = 4
  upper                        = false
  lower                        = true
  numeric                      = false
  special                      = false
}

locals {
  admin_cidr_ranges            = sort(distinct(concat([for range in var.admin_ip_ranges : cidrsubnet(range,0,0)],tolist([local.terraform_ip_address])))) # Make sure ranges have correct base address

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
  terraform_ip_address         = chomp(data.http.terraform_ip_address.response_body)
  terraform_ip_prefix          = jsondecode(chomp(data.http.terraform_ip_prefix.response_body)).data.prefix
}

resource azurerm_resource_group rg {
  name                         = terraform.workspace == "default" ? "${var.resource_prefix}-private-keyvault-${local.initial_suffix}" : "${var.resource_prefix}-${terraform.workspace}-keyvault-variable-group-${local.initial_suffix}"
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
  log_analytics_workspace_resource_id = local.log_analytics_workspace_id
  private_endpoint_subnet_id   = module.network.private_endpoint_subnet_id
  resource_group_name          = azurerm_resource_group.rg.name
  secrets                      = var.variable_group_variables
  service_principal_object_id  = module.service_principal.principal_id
  tags                         = local.tags
}

module network {
  source                       = "./modules/network"

  address_space                = "10.201.0.0/22"
  admin_cidr_ranges            = local.admin_cidr_ranges
  bastion_tags                 = var.bastion_tags
  deploy_bastion               = var.deploy_bastion
  diagnostics_storage_id       = azurerm_storage_account.diagnostics.id
  enable_public_access         = var.enable_public_access
  location                     = var.location
  log_analytics_workspace_resource_id = local.log_analytics_workspace_id
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
  name                         = "keyvault-variable-group-${terraform.workspace}-${local.suffix}"
  service_principal_app_id     = module.service_principal.application_id
  service_principal_key        = module.service_principal.secret
  subscription_id              = data.azurerm_subscription.current.subscription_id
  subscription_name            = data.azurerm_subscription.current.display_name
  tenant_id                    = data.azuread_client_config.current.tenant_id
  variable_names               = module.key_vault.secret_names
}