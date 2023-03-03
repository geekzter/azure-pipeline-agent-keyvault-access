resource azuredevops_project demo_project {
  name                         = var.name
  work_item_template           = "Agile"
  version_control              = "Git"
  visibility                   = "private"
  description                  = "Managed by Terraform"
}

resource azuredevops_serviceendpoint_azurerm service_connection {
  project_id                   = azuredevops_project.demo_project.id
  service_endpoint_name        = "Key Vault Service Connection"
  description                  = "Managed by Terraform"
  credentials {
    serviceprincipalid         = var.service_principal_app_id
    serviceprincipalkey        = var.service_principal_key
  }
  azurerm_spn_tenantid         = var.tenant_id
  azurerm_subscription_id      = var.subscription_id
  azurerm_subscription_name    = var.subscription_name
}

# resource azuredevops_variable_group kay_vault_variable_group {
#   project_id                   = azuredevops_project.demo_project.id
#   name                         = "Key Vault Variable Group"
#   description                  = "Key Vault Variable Group"
#   allow_access                 = true

#   key_vault {
#     name                       = "example-kv"
#     service_endpoint_id        = azuredevops_serviceendpoint_azurerm.service_connection.id
#   }

#   variable {
#     name                       = "key1"
#   }

#   variable {
#     name                       = "key2"
#   }
# }