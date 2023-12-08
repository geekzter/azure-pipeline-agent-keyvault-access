locals {
  client_object_id_map         = merge(
    {
      user_assigned            = azurerm_user_assigned_identity.agents.principal_id
    },var.create_devops_project ? {
      service_connection       = var.create_devops_project ? module.service_principal.0.principal_id : null
      # system_assigned          = module.self_hosted_linux_agents.0.identity_object_id
    } : {}
  )
}

resource azurerm_user_assigned_identity agents {
  name                         = "${azurerm_resource_group.rg.name}-agent-identity"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location

  tags                         = local.tags
}

resource azurerm_role_assignment client_key_vault_reader {
  scope                        = azurerm_resource_group.rg.id
  role_definition_name         = "Reader"
  principal_id                 = each.value

  for_each                     = local.client_object_id_map
}

resource azurerm_role_assignment client_key_vault_data_reader {
  scope                        = azurerm_resource_group.rg.id
  role_definition_name         = "Key Vault Secrets User"
  principal_id                 = each.value

  for_each                     = var.use_key_vault_aad_rbac ? local.client_object_id_map : {}
}

resource azurerm_role_assignment terraform_key_vault_data_access {
  scope                        = azurerm_resource_group.rg.id
  role_definition_name         = "Key Vault Secrets Officer"
  principal_id                 = data.azuread_client_config.current.object_id 

  count                        = var.use_key_vault_aad_rbac ? 1 : 0
}

resource azurerm_role_assignment system_assigned_key_vault_reader {
  scope                        = azurerm_resource_group.rg.id
  role_definition_name         = "Reader"
  principal_id                 = module.self_hosted_linux_agents.0.identity_object_id

  count                        = var.create_devops_project && var.create_agent ? 1 : 0
}

resource azurerm_role_assignment service_connection_vm {
  scope                        = azurerm_resource_group.rg.id
  role_definition_name         = "Virtual Machine Contributor" # Start agent JIT
  principal_id                 = module.service_principal.0.principal_id

  count                        = var.create_devops_project ? 1 : 0
}