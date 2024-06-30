module key_vault {
  source                       = "./modules/azure-key-vault"
  allow_cidr_ranges            = local.allow_ip_ranges
  client_object_ids            = [for k,v in local.client_object_id_map : v]
  configure_private_link       = var.create_agent
  enable_public_access         = var.enable_azure_key_vault_public_access
  generate_secrets             = var.azdo_variable_group_variables_to_generate
  location                     = var.azure_location
  log_analytics_workspace_resource_id = local.log_analytics_workspace_id
  name                         = local.key_vault_name
  private_endpoint_subnet_id   = var.create_agent ?  module.network.0.private_endpoint_subnet_id : null
  resource_group_name          = azurerm_resource_group.rg.name
  secrets                      = var.azdo_variable_group_variables
  tags                         = local.tags
  use_aad_rbac                 = var.use_azure_key_vault_aad_rbac

  depends_on = [
    azurerm_role_assignment.terraform_key_vault_data_access
  ]
}

module network {
  source                       = "./modules/azure-network"

  address_space                = "10.201.0.0/22"
  admin_cidr_ranges            = local.allow_ip_ranges
  bastion_tags                 = var.azure_bastion_tags
  deploy_bastion               = var.create_azure_bastion
  diagnostics_storage_id       = azurerm_storage_account.diagnostics.id
  enable_public_access         = var.enable_azure_key_vault_public_access
  location                     = var.azure_location
  log_analytics_workspace_resource_id = local.log_analytics_workspace_id
  resource_group_name          = azurerm_resource_group.rg.name
  tags                         = local.tags

  count                        = var.create_agent ? 1 : 0
}

module service_principal {
  source                       = "./modules/entra-app-registration"
  create_federation            = var.create_entra_federation
  federation_subject           = var.create_entra_federation ? module.azure_devops_service_connection.0.service_connection_oidc_subject : null
  issuer                       = var.create_entra_federation ? module.azure_devops_service_connection.0.service_connection_oidc_issuer : null
  multi_tenant                 = false
  name                         = "${var.resource_prefix}-keyvault-service-connection-${terraform.workspace}-${local.suffix}"
  notes                        = local.notes
  owner_object_ids             = var.entra_owner_object_ids
  service_management_reference = var.entra_service_management_reference

  count                        = var.create_azdo_resources ? 1 : 0
}

module azure_devops_project {
  source                       = "./modules/azure-devops-project"
  create_project               = var.azdo_project != null && var.azdo_project != "" ? false : true
  name                         = var.azdo_project != null && var.azdo_project != "" ? var.azdo_project : "keyvault-variable-group-${terraform.workspace}-${local.suffix}"

  count                        = var.create_azdo_resources ? 1 : 0
}

module azure_devops_service_connection {
  source                       = "./modules/azure-devops-service-connection"
  application_id               = module.service_principal.0.application_id
  application_secret           = var.create_entra_federation ? null : module.service_principal.0.secret
  authentication_scheme        = var.create_entra_federation ? "WorkloadIdentityFederation" : "ServicePrincipal"
  create_identity              = false
  project_id                   = module.azure_devops_project.0.project_id
  tenant_id                    = data.azuread_client_config.current.tenant_id
  service_connection_name      = local.key_vault_name
  subscription_id              = data.azurerm_subscription.current.subscription_id
  subscription_name            = data.azurerm_subscription.current.display_name

  count                        = var.create_azdo_resources ? 1 : 0
}

module azure_pipelines {
  source                       = "./modules/azure-pipelines"
  create_pool                  = var.create_agent
  create_pipeline              = var.create_azdo_pipeline
  key_vault_id                 = module.key_vault.key_vault_id
  key_vault_service_connection_id = module.azure_devops_service_connection.0.service_connection_id
  name                         = var.azdo_project != null && var.azdo_project != "" ? var.azdo_project : "keyvault-variable-group-${terraform.workspace}-${local.suffix}"
  project_id                   = module.azure_devops_project.0.project_id
  suffix                       = local.suffix
  use_variable_group           = var.enable_azure_key_vault_public_access || var.create_agent 
  variable_names               = module.key_vault.secret_names

  depends_on                   = [
    module.azure_devops_service_connection,
    module.service_principal,
    azurerm_role_assignment.client_key_vault_reader
  ]

  count                        = var.create_azdo_resources ? 1 : 0
}

module self_hosted_linux_agents {
  source                       = "./modules/azure-pipelines-agent"

  admin_cidr_ranges            = local.allow_ip_ranges

  create_public_ip_address     = false
  deploy_agent                 = true
  deploy_non_essential_vm_extensions = false

  devops_org_url               = local.azdo_org_url
  devops_pat                   = data.external.azdo_token.result.accessToken

  environment_variables        = local.environment_variables
  location                     = var.azure_location
  log_analytics_workspace_resource_id = local.log_analytics_workspace_id

  computer_name                = "linuxagent"
  name                         = "${azurerm_resource_group.rg.name}-linux-agent"
  os_image_id                  = var.azure_agent_linux_os_image_id
  os_offer                     = var.azure_agent_linux_os_offer
  os_publisher                 = var.azure_agent_linux_os_publisher
  os_sku                       = var.azure_agent_linux_os_sku
  os_version                   = var.azure_agent_linux_os_version
  pipeline_agent_name          = local.pipeline_agent_name
  pipeline_agent_pool          = module.azure_pipelines.0.pool_name
  pipeline_agent_version_id    = "latest"
  storage_type                 = var.azure_agent_linux_storage_type
  vm_size                      = var.azure_agent_linux_vm_size

  enable_public_access         = var.enable_azure_key_vault_public_access
  install_tools                = var.azure_agent_linux_tools
  outbound_ip_address          = module.network.0.outbound_ip_address
  prepare_host                 = var.prepare_host
  resource_group_name          = azurerm_resource_group.rg.name
  shutdown_time                = var.shutdown_time
  ssh_public_key               = var.azure_agent_ssh_public_key
  tags                         = local.tags
  timezone                     = var.timezone
  subnet_id                    = module.network.0.self_hosted_agents_subnet_id
  suffix                       = local.suffix
  user_assigned_identity_id    = azurerm_user_assigned_identity.agents.id
  user_name                    = var.azure_agent_user_name
  user_password                = local.password
  vm_accelerated_networking    = false
  depends_on                   = [
    module.network
  ]

  count                        = var.create_azdo_resources && var.create_agent ? 1 : 0
}