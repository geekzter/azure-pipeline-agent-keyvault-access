resource azuredevops_serviceendpoint_azurerm service_connection {
  project_id                   = azuredevops_project.demo_project.id
  service_endpoint_name        = var.key_vault_name
  description                  = "Key Vault Variable Group managed by Terraform"
  credentials {
    serviceprincipalid         = var.service_principal_app_id
    serviceprincipalkey        = var.service_principal_key
  }
  azurerm_spn_tenantid         = var.tenant_id
  azurerm_subscription_id      = var.subscription_id
  azurerm_subscription_name    = var.subscription_name
}

resource azuredevops_resource_authorization service_connection {
  project_id                   = azuredevops_project.demo_project.id
  resource_id                  = azuredevops_serviceendpoint_azurerm.service_connection.id
  authorized                   = true
}

resource azuredevops_variable_group key_vault_variable_group {
  project_id                   = azuredevops_project.demo_project.id
  name                         = var.key_vault_name
  description                  = "Key Vault Variable Group managed by Terraform"
  allow_access                 = true

  key_vault {
    name                       = var.key_vault_name
    service_endpoint_id        = azuredevops_serviceendpoint_azurerm.service_connection.id
  }

  dynamic variable {
    for_each                   = toset(var.variable_names)
    content {
      name                     = variable.key
    }
  }  
}