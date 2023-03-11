module key_vault {
  source                       = "./modules/key-vault"
  admin_cidr_ranges            = local.admin_cidr_ranges
  client_object_ids            = [for k,v in local.client_object_id_map : v]
  enable_public_access         = var.enable_public_access
  location                     = var.location
  log_analytics_workspace_resource_id = local.log_analytics_workspace_id
  private_endpoint_subnet_id   = module.network.private_endpoint_subnet_id
  resource_group_name          = azurerm_resource_group.rg.name
  secrets                      = var.variable_group_variables
  tags                         = local.tags
  use_aad_rbac                 = var.use_key_vault_aad_rbac

  depends_on = [
    azurerm_role_assignment.terraform_key_vault_data_access
  ]
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
  key_vault_id                 = module.key_vault.key_vault_id
  name                         = "keyvault-variable-group-${terraform.workspace}-${local.suffix}"
  service_principal_app_id     = module.service_principal.application_id
  service_principal_key        = module.service_principal.secret
  subscription_id              = data.azurerm_subscription.current.subscription_id
  subscription_name            = data.azurerm_subscription.current.display_name
  tenant_id                    = data.azuread_client_config.current.tenant_id
  variable_names               = module.key_vault.secret_names

  depends_on                   = [
    # azurerm_role_assignment.client_key_vault_reader["service_connection"],
    # azurerm_role_assignment.service_connection_resource_group_reader
    azurerm_role_assignment.client_key_vault_reader
  ]
}

module self_hosted_linux_agents {
  source                       = "./modules/self-hosted-linux-agent"

  admin_cidr_ranges            = local.admin_cidr_ranges

  create_public_ip_address     = false
  deploy_agent                 = true
  deploy_non_essential_vm_extensions = false

  devops_org_url               = local.devops_org_url
  devops_pat                   = var.devops_pat

  environment_variables        = local.environment_variables
  location                     = var.location
  log_analytics_workspace_resource_id = local.log_analytics_workspace_id

  computer_name                = "linuxagent"
  name                         = "${azurerm_resource_group.rg.name}-linux-agent"
  os_image_id                  = var.linux_os_image_id
  os_offer                     = var.linux_os_offer
  os_publisher                 = var.linux_os_publisher
  os_sku                       = var.linux_os_sku
  os_version                   = var.linux_os_version
  pipeline_agent_name          = local.pipeline_agent_name
  pipeline_agent_pool          = module.devops_project.pool_name
  pipeline_agent_version_id    = "latest"
  storage_type                 = var.linux_storage_type
  vm_size                      = var.linux_vm_size

  enable_public_access         = var.enable_public_access
  install_tools                = var.linux_tools
  outbound_ip_address          = module.network.outbound_ip_address
  prepare_host                 = var.prepare_host
  resource_group_name          = azurerm_resource_group.rg.name
  shutdown_time                = var.shutdown_time
  ssh_public_key               = var.ssh_public_key
  tags                         = local.tags
  timezone                     = var.timezone
  subnet_id                    = module.network.self_hosted_agents_subnet_id
  suffix                       = local.suffix
  user_assigned_identity_id    = azurerm_user_assigned_identity.agents.id
  user_name                    = var.user_name
  user_password                = local.password
  vm_accelerated_networking    = false
  depends_on                   = [
    module.network
  ]
}