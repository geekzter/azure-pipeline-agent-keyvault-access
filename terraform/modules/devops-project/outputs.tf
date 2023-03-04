output project_id {
  value       = azuredevops_project.demo_project.id
}
output project_name {
  value       = azuredevops_project.demo_project.name
}

output service_connection_id {
  value       = azuredevops_serviceendpoint_azurerm.service_connection.id
}
output service_connection_name {
  value       = azuredevops_serviceendpoint_azurerm.service_connection.service_endpoint_name
}