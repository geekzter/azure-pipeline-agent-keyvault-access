resource azuredevops_project demo_project {
  name                         = var.name
  work_item_template           = "Agile"
  version_control              = "Git"
  visibility                   = "private"
  description                  = "Key Vault Variable Group demo managed by Terraform"

  features = {
    artifacts                  = "disabled"
    boards                     = "disabled"
    pipelines                  = "enabled"
    repositories               = "disabled"
    testplans                  = "disabled"
  }
}

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

resource azuredevops_variable_group kay_vault_variable_group {
  project_id                   = azuredevops_project.demo_project.id
  name                         = var.key_vault_name
  description                  = "Key Vault Variable Group managed by Terraform"
  allow_access                 = true

  key_vault {
    name                       = var.key_vault_name
    service_endpoint_id        = azuredevops_serviceendpoint_azurerm.service_connection.id
  }

  variable {
    name                       = "initial-variable"
  }

  lifecycle {
    ignore_changes             = [
      variable
    ]
  }  
}