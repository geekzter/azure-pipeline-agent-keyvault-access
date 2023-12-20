output project_id {
  value       = local.project_id
}
output project_name {
  value       = local.project_name
}
output project_url {
  value       = "${data.azuredevops_client_config.current.organization_url}/${local.project_name}"
}