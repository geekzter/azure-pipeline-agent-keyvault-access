locals {
  key_vault_name               = split("/", var.key_vault_id)[8]
  resource_group_name          = split("/", var.key_vault_id)[4]
  pipeline_definitions         = var.create_pipeline ? {
    "${var.pipeline_name}"     = "azure-key-vault-info.yml"
  } : {}
}

resource azuredevops_serviceendpoint_azurerm service_connection {
  project_id                   = local.project_id
  service_endpoint_name        = local.key_vault_name
  description                  = "Key Vault integration managed by Terraform"
  credentials {
    serviceprincipalid         = var.service_principal_app_id
    serviceprincipalkey        = var.service_principal_key
  }
  azurerm_spn_tenantid         = var.tenant_id
  azurerm_subscription_id      = var.subscription_id
  azurerm_subscription_name    = var.subscription_name
}

resource azuredevops_pipeline_authorization service_connection {
  project_id                   = local.project_id
  resource_id                  = azuredevops_serviceendpoint_azurerm.service_connection.id
  type                         = "endpoint"
}

resource azuredevops_variable_group key_vault_variable_group {
  project_id                   = local.project_id
  name                         = local.key_vault_name
  description                  = "Key Vault integration managed by Terraform"
  allow_access                 = true

  key_vault {
    name                       = local.key_vault_name
    service_endpoint_id        = azuredevops_serviceendpoint_azurerm.service_connection.id
  }

  dynamic variable {
    for_each                   = toset(var.variable_names)
    content {
      name                     = variable.key
    }
  }  
}

resource azuredevops_git_repository_file pipeline_yaml {
  repository_id                = azuredevops_git_repository.demo_repo.0.id
  file                         = each.value
  content                      = file("${path.root}/../pipelines/${each.value}")
  branch                       = "refs/heads/main"
  commit_message               = "Pipeline YAML file, commit from Terraform"
  overwrite_on_create          = false

  for_each                     = local.pipeline_definitions
}

resource azuredevops_build_definition pipeline {
  project_id                   = local.project_id
  name                         = each.key

  ci_trigger {
    use_yaml                   = true
  }

  path                         = "\\demo"

  repository {
    repo_type                  = "TfsGit"
    repo_id                    = azuredevops_git_repository.demo_repo.0.id
    branch_name                = azuredevops_git_repository.demo_repo.0.default_branch
    yml_path                   = each.value
  }

  variable_groups              = [
    azuredevops_variable_group.key_vault_variable_group.id
  ]

  variable {
    name                       = "poolName"
    value                      = var.create_pool ? azuredevops_agent_pool.pool.0.name : "Azure Pipelines"
  }
  variable {
    name                       = "keyVaultId"
    value                      = var.key_vault_id
  }
  variable {
    name                       = "keyVaultName"
    value                      = local.key_vault_name
  }
  variable {
    name                       = "resourceGroupName"
    value                      = local.resource_group_name
  }
  variable {
    name                       = "serviceConnectionName"
    value                      = azuredevops_serviceendpoint_azurerm.service_connection.service_endpoint_name
  }

  for_each                     = local.pipeline_definitions
  depends_on                   = [
    azuredevops_git_repository_file.pipeline_yaml
  ]
}