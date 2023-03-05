locals {
  client_object_id_map         = {
    user_assigned              = azurerm_user_assigned_identity.agents.principal_id
    service_connection         = module.service_principal.principal_id
    # system_assigned            = module.self_hosted_linux_agents.identity_object_id
  }
}

resource azurerm_user_assigned_identity agents {
  name                         = "${azurerm_resource_group.rg.name}-agent-identity"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location

  tags                         = local.tags
}

# resource azurerm_role_assignment client_key_vault_reader {
#   scope                        = module.key_vault.key_vault_id
#   role_definition_name         = "Reader"
#   principal_id                 = each.value

#   for_each                     = local.client_object_id_map
# }

resource azurerm_role_assignment client_key_vault_data_reader {
  scope                        = module.key_vault.key_vault_id
  role_definition_name         = "Key Vault Secrets User"
  principal_id                 = each.value

  for_each                     = local.client_object_id_map
}

resource azurerm_role_assignment user_assigned_key_vault_reader {
  scope                        = module.key_vault.key_vault_id
  role_definition_name         = "Reader"
  principal_id                 = azurerm_user_assigned_identity.agents.principal_id
}

resource azurerm_role_assignment system_assigned_key_vault_reader {
  scope                        = module.key_vault.key_vault_id
  role_definition_name         = "Reader"
  principal_id                 = module.self_hosted_linux_agents.identity_object_id
}

resource azurerm_role_assignment service_connection_key_vault_reader {
  scope                        = module.key_vault.key_vault_id
  role_definition_name         = "Reader"
  principal_id                 = module.service_principal.principal_id
}