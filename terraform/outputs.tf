output key_vault_id {
  value       = module.key_vault.key_vault_id
}
output key_vault_name {
  value       = module.key_vault.key_vault_name
}

output pool_id {
  value       = module.devops_project.pool_id
}
output pool_url {
  value       = module.devops_project.pool_url
}
output queue_id {
  value       = module.devops_project.queue_id
}
output queue_url {
  value       = module.devops_project.queue_url
}

output project_id {
  value       = module.devops_project.project_id
}
output project_name {
  value       = module.devops_project.project_name
}
output project_url {
  value       = module.devops_project.project_url
}

output resource_group_id {
  value       = azurerm_resource_group.rg.id
}
output resource_group_name {
  value       = azurerm_resource_group.rg.name
}
output resource_group_url {
  value       = "https://portal.azure.com/#@/resource${azurerm_resource_group.rg.id}/overview"
}

output service_connection_id {
  value       = module.devops_project.service_connection_id
}
output service_connection_name {
  value       = module.devops_project.service_connection_name
}

output service_principal_application_id {
  value       = module.service_principal.application_id
}
output service_principal_application_url {
  value       = module.service_principal.application_url
}
output service_principal_principal_id {
  value       = module.service_principal.principal_id
}
output service_principal_principal_url {
  value       = module.service_principal.principal_url
}

output variable_group_variable_names {
  value       = module.key_vault.secret_names
}

output variable_group_id {
  value       = module.devops_project.variable_group_id
}
output variable_group_name {
  value       = module.devops_project.variable_group_name
}
output variable_group_url {
  value       = module.devops_project.variable_group_url
}

output virtual_network_id {
  value       = module.network.virtual_network_id
}