output aad_service_principal_application_id {
  value       = var.create_azdo_resources ? module.service_principal.0.application_id : null
}
output aad_service_principal_application_url {
  value       = var.create_azdo_resources ? module.service_principal.0.application_url : null
}
output aad_service_principal_principal_id {
  value       = var.create_azdo_resources ? module.service_principal.0.principal_id : null
}
output aad_service_principal_principal_url {
  value       = var.create_azdo_resources ? module.service_principal.0.principal_url : null
}

output azdo_pipelines {
  value       = var.create_azdo_resources ? module.azure_pipelines.0.pipelines : null
}
output azdo_pool_id {
  value       = var.create_azdo_resources ? module.azure_pipelines.0.pool_id : null
}
output azdo_pool_name {
  value       = var.create_azdo_resources ? module.azure_pipelines.0.pool_name : null
}
output azdo_pool_url {
  value       = var.create_azdo_resources ? module.azure_pipelines.0.pool_url : null
}
output azdo_queue_id {
  value       = var.create_azdo_resources ? module.azure_pipelines.0.queue_id : null
}
output azdo_queue_url {
  value       = var.create_azdo_resources ? module.azure_pipelines.0.queue_url : null
}
output azdo_project_id {
  value       = var.create_azdo_resources ? module.azure_devops_project.0.project_id : null
}
output azdo_project_name {
  value       = var.create_azdo_resources ? module.azure_devops_project.0.project_name : null
}
output azdo_project_url {
  value       = var.create_azdo_resources ? module.azure_devops_project.0.project_url : null
}
output azdo_repo_id {
  value       = var.create_azdo_resources ? module.azure_pipelines.0.repo_id : null
}
output azdo_repo_name {
  value       = var.create_azdo_resources ? module.azure_pipelines.0.repo_name : null
}
output azdo_repo_url {
  value       = var.create_azdo_resources ? module.azure_pipelines.0.repo_url : null
}
output azdo_repo_rest_url {
  value       = var.create_azdo_resources ? module.azure_pipelines.0.repo_rest_url : null
}
output azdo_service_connection_id {
  value       = var.create_azdo_resources ? module.azure_devops_service_connection.0.service_connection_id : null
}
output azdo_service_connection_name {
  value       = var.create_azdo_resources ? module.azure_devops_service_connection.0.service_connection_name : null
}
output azdo_service_connection_oidc_issuer {
  value       = var.create_azdo_resources ? module.azure_devops_service_connection.0.service_connection_oidc_issuer : null
}
output azdo_service_connection_oidc_subject {
  value       = var.create_azdo_resources ? module.azure_devops_service_connection.0.service_connection_oidc_subject : null
}
output azdo_service_connection_url {
  value       = var.create_azdo_resources ? module.azure_devops_service_connection.0.service_connection_url : null
}
output azdo_variable_group_id {
  value       = var.create_azdo_resources ? module.azure_pipelines.0.variable_group_id : null
}
output azdo_variable_group_name {
  value       = var.create_azdo_resources ? module.azure_pipelines.0.variable_group_name : null
}
output azdo_variable_group_url {
  value       = var.create_azdo_resources ? module.azure_pipelines.0.variable_group_url : null
}
output azdo_variable_group_variable_names {
  value       = var.create_azdo_resources ? module.key_vault.secret_names : null
}

output azure_admin_ip_ranges {
  value       = local.allow_ip_ranges
}

# output azure_agent_vm_id {
#   value       = var.create_azdo_resources && var.create_agent ? module.self_hosted_linux_agents.vm_id : null
# }
output azure_agent_vm_url {
  value       = var.create_azdo_resources && var.create_agent ? "https://portal.azure.com/#@${data.azurerm_subscription.current.tenant_id}/resource${module.self_hosted_linux_agents.0.vm_id}/overview" : null
}

# output azure_bastion_id {
#   value       = var.create_bastion ? module.network.bastion_id : null
# }
output azure_bastion_name {
  value       = var.create_bastion ? module.network.bastion_name : null
}
output azure_bastion_url {
  value       = var.create_bastion ? "https://portal.azure.com/#@${data.azurerm_subscription.current.tenant_id}/resource${module.network.bastion_id}/overview" : null
}
# output azure_key_vault_id {
#   value       = module.key_vault.key_vault_id
# }
output azure_key_vault_name {
  value       = module.key_vault.key_vault_name
}
output azure_key_vault_url {
  value       = "https://portal.azure.com/#@${data.azurerm_subscription.current.tenant_id}/resource${module.key_vault.key_vault_id}/overview"
}
# output azure_resource_group_id {
#   value       = azurerm_resource_group.rg.id
# }
output azure_resource_group_name {
  value       = azurerm_resource_group.rg.name
}
output azure_resource_group_url {
  value       = "https://portal.azure.com/#@${data.azurerm_subscription.current.tenant_id}/resource${azurerm_resource_group.rg.id}/overview"
}
# output azure_virtual_network_id {
#   value       = module.network.virtual_network_id
# }
output azure_virtual_network_name {
  value       = module.network.virtual_network_name
}
output azure_virtual_network_url {
  value       = "https://portal.azure.com/#@${data.azurerm_subscription.current.tenant_id}/resource${azurerm_resource_group.rg.id}/overview"
}

output verify_keyvault_access_script {
  value       = abspath(local_file.verify_keyvault_access_script.filename)
}