output pool_id {
  value       = azuredevops_agent_pool.pool.id
}
output pool_url {
  value       = "${data.azuredevops_client_config.current.organization_url}/_settings/agentpools?poolId=${azuredevops_agent_pool.pool.id}&view=jobs"
}
output queue_id {
  value       = azuredevops_agent_queue.pool.id
}
output queue_url {
  value       = "${data.azuredevops_client_config.current.organization_url}/${azuredevops_project.demo_project.name}/_settings/agentqueues?queueId=${azuredevops_agent_queue.pool.id}&view=jobs"
}

output project_id {
  value       = azuredevops_project.demo_project.id
}
output project_name {
  value       = azuredevops_project.demo_project.name
}
output project_url {
  value       = "${data.azuredevops_client_config.current.organization_url}/${azuredevops_project.demo_project.name}"
}

output service_connection_id {
  value       = azuredevops_serviceendpoint_azurerm.service_connection.id
}
output service_connection_name {
  value       = azuredevops_serviceendpoint_azurerm.service_connection.service_endpoint_name
}
output service_connection_url {
  value       = "${data.azuredevops_client_config.current.organization_url}/${azuredevops_project.demo_project.name}/_settings/adminservices?resourceId=${azuredevops_serviceendpoint_azurerm.service_connection.id}"
}

output variable_group_id {
  value       = azuredevops_variable_group.key_vault_variable_group.id
}
output variable_group_name {
  value       = azuredevops_variable_group.key_vault_variable_group.name
}
output variable_group_url {
  value       = "${data.azuredevops_client_config.current.organization_url}/${azuredevops_project.demo_project.name}/_library?itemType=VariableGroups&view=VariableGroupView&variableGroupId=${azuredevops_variable_group.key_vault_variable_group.id}&path=${azuredevops_variable_group.key_vault_variable_group.name}"
}