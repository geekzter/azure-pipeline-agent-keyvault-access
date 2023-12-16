output pipelines {
  value       = {for pipeline_name,yaml_file in local.pipeline_definitions : pipeline_name => {
    id        = azuredevops_build_definition.pipeline[pipeline_name].id
    name      = azuredevops_build_definition.pipeline[pipeline_name].name
    url       = "${data.azuredevops_client_config.current.organization_url}/${var.project_id}/_build?definitionId=${azuredevops_build_definition.pipeline[pipeline_name].id}"
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
  value       = var.create_pool ? "${data.azuredevops_client_config.current.organization_url}/${var.project_id}/_settings/agentqueues?queueId=${azuredevops_agent_queue.pool.0.id}&view=jobs" : null
}

output repo_id {
  value       = var.create_pipeline ? azuredevops_git_repository.demo_repo.0.id : null
}
output repo_name {
  value       = var.create_pipeline ? azuredevops_git_repository.demo_repo.0.name : null
}
output repo_url {
  value       = var.create_pipeline ? azuredevops_git_repository.demo_repo.0.web_url : null
}
output repo_rest_url {
  value       = var.create_pipeline ? azuredevops_git_repository.demo_repo.0.url : null
}

output variable_group_id {
  value       = azuredevops_variable_group.key_vault_variable_group.id
}
output variable_group_name {
  value       = azuredevops_variable_group.key_vault_variable_group.name
}
output variable_group_url {
  value       = "${data.azuredevops_client_config.current.organization_url}/${var.project_id}/_library?itemType=VariableGroups&view=VariableGroupView&variableGroupId=${azuredevops_variable_group.key_vault_variable_group.id}&path=${azuredevops_variable_group.key_vault_variable_group.name}"
}