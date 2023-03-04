output key_vault_id {
  value       = module.key_vault.key_vault_id
}
output key_vault_name {
  value       = module.key_vault.key_vault_name
}

output project_id {
  value       = module.devops_project.project_id
}
output project_name {
  value       = module.devops_project.project_name
}

output resource_group_id {
  value       = azurerm_resource_group.rg.id
}
output resource_group_name {
  value       = azurerm_resource_group.rg.name
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
output service_principal_principal_id {
  value       = module.service_principal.principal_id
}

output variable_group_variable_names {
  value       = module.key_vault.secret_names
}