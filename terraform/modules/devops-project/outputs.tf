output pipelines {
  value       = {for pipeline_name,yaml_file in local.pipeline_definitions : pipeline_name => {
    id        = azuredevops_build_definition.pipeline[pipeline_name].id
    name      = azuredevops_build_definition.pipeline[pipeline_name].name
    url       = "${data.azuredevops_client_config.current.organization_url}/${local.project_name}/_build?definitionId=${azuredevops_build_definition.pipeline[pipeline_name].id}"
    yaml_file = yaml_file
  }}
}

output pool_id {
  value       = var.create_pool ? azuredevops_agent_pool.pool.0.id : null
}
output pool_name {
  value       = var.create_pool ? azuredevops_agent_pool.pool.0.name : null
}
output pool_url {
  value       = var.create_pool ? "${data.azuredevops_client_config.current.organization_url}/_settings/agentpools?poolId=${azuredevops_agent_pool.pool.0.id}&view=jobs" : null
}
output queue_id {
  value       = var.create_pool ? azuredevops_agent_queue.pool.0.id : null
}
output queue_url {
  value       = var.create_pool ? "${data.azuredevops_client_config.current.organization_url}/${local.project_name}/_settings/agentqueues?queueId=${azuredevops_agent_queue.pool.0.id}&view=jobs" : null
}

output project_id {
  value       = local.project_id
}
output project_name {
  value       = local.project_name
}
output project_url {
  value       = "${data.azuredevops_client_config.current.organization_url}/${local.project_name}"
}

output repo_id {
  value       = var.create_pipeline ? azuredevops_git_repository.demo_repo.0.id : null
}
output repo_name {
  value       = var.create_pipeline ? azuredevops_git_repository.demo_repo.0.name : null
}
output repo_url {
  value       = var.create_pipeline ? "${data.azuredevops_client_config.current.organization_url}/${local.project_name}/_git/${azuredevops_git_repository.demo_repo.0.name}" : null
}

output service_connection_id {
  value       = azuredevops_serviceendpoint_azurerm.service_connection.id
}
output service_connection_name {
  value       = azuredevops_serviceendpoint_azurerm.service_connection.service_endpoint_name
}
output service_connection_url {
  value       = "${data.azuredevops_client_config.current.organization_url}/${local.project_name}/_settings/adminservices?resourceId=${azuredevops_serviceendpoint_azurerm.service_connection.id}"
}
output service_connection_oidc_issuer {
  value       = azuredevops_serviceendpoint_azurerm.service_connection.workload_identity_federation_issuer
}
output service_connection_oidc_subject {
  value       = azuredevops_serviceendpoint_azurerm.service_connection.workload_identity_federation_subject
}

output variable_group_id {
  value       = azuredevops_variable_group.key_vault_variable_group.id
}
output variable_group_name {
  value       = azuredevops_variable_group.key_vault_variable_group.name
}
output variable_group_url {
  value       = "${data.azuredevops_client_config.current.organization_url}/${local.project_name}/_library?itemType=VariableGroups&view=VariableGroupView&variableGroupId=${azuredevops_variable_group.key_vault_variable_group.id}&path=${azuredevops_variable_group.key_vault_variable_group.name}"
}