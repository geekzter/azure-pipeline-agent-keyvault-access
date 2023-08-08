output aad_service_principal_application_id {
  value       = module.service_principal.application_id
}
output aad_service_principal_application_url {
  value       = module.service_principal.application_url
}
output aad_service_principal_principal_id {
  value       = module.service_principal.principal_id
}
output aad_service_principal_principal_url {
  value       = module.service_principal.principal_url
}

output azdo_pipelines {
  value       = module.devops_project.pipelines
}
output azdo_pool_id {
  value       = module.devops_project.pool_id
}
output azdo_pool_name {
  value       = module.devops_project.pool_name
}
output azdo_pool_url {
  value       = module.devops_project.pool_url
}
output azdo_queue_id {
  value       = module.devops_project.queue_id
}
output azdo_queue_url {
  value       = module.devops_project.queue_url
}
output azdo_project_id {
  value       = module.devops_project.project_id
}
output azdo_project_name {
  value       = module.devops_project.project_name
}
output azdo_project_url {
  value       = module.devops_project.project_url
}
output azdo_repo_id {
  value       = module.devops_project.repo_id
}
output azdo_repo_name {
  value       = module.devops_project.repo_name
}
output azdo_repo_url {
  value       = module.devops_project.repo_url
}
output azdo_service_connection_id {
  value       = module.devops_project.service_connection_id
}
output azdo_service_connection_name {
  value       = module.devops_project.service_connection_name
}
output azdo_service_connection_url {
  value       = module.devops_project.service_connection_url
}
output azdo_variable_group_id {
  value       = module.devops_project.variable_group_id
}
output azdo_variable_group_name {
  value       = module.devops_project.variable_group_name
}
output azdo_variable_group_url {
  value       = module.devops_project.variable_group_url
}
output azdo_variable_group_variable_names {
  value       = module.key_vault.secret_names
}

output azure_admin_cidr_ranges {
  value       = local.admin_cidr_ranges
}

# output azure_agent_vm_id {
#   value       = module.self_hosted_linux_agents.vm_id
# }
output azure_agent_vm_url {
  value       = "https://portal.azure.com/#@${data.azurerm_subscription.current.tenant_id}/resource${module.self_hosted_linux_agents.vm_id}/overview"
}

# output azure_bastion_id {
#   value       = var.deploy_bastion ? module.network.bastion_id : null
# }
output azure_bastion_name {
  value       = var.deploy_bastion ? module.network.bastion_name : null
}
output azure_bastion_url {
  value       = var.deploy_bastion ? "https://portal.azure.com/#@${data.azurerm_subscription.current.tenant_id}/resource${module.network.bastion_id}/overview" : null
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