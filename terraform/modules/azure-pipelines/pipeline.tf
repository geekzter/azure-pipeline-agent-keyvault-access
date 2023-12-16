locals {
  key_vault_name               = split("/", var.key_vault_id)[8]
  resource_group_name          = split("/", var.key_vault_id)[4]
  pipeline_definitions         = var.create_pipeline ? {
    "key-vault-${terraform.workspace}" = "azure-key-vault-info.yml"
  } : {}
}

resource azuredevops_variable_group key_vault_variable_group {
  project_id                   = var.project_id
  name                         = local.key_vault_name
  description                  = "Key Vault integration (${length(var.variable_names)} variables) managed by Terraform"
  allow_access                 = true

  key_vault {
    name                       = local.key_vault_name
    service_endpoint_id        = var.key_vault_service_connection_id
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
  content                      = templatefile("${path.root}/../pipelines/${each.value}", {
    key_vault_name             = local.key_vault_name
    start_agents               = var.create_pool ? "true" : "false"
    use_variable_group         = var.use_variable_group ? "true" : "false"
  })
  branch                       = "refs/heads/main"
  commit_message               = "Pipeline YAML file, commit from Terraform"
  overwrite_on_create          = false

  for_each                     = local.pipeline_definitions
}

resource azuredevops_build_definition pipeline {
  project_id                   = var.project_id
  name                         = each.key

  ci_trigger {
    use_yaml                   = true
  }

  path                         = "\\key-vault"

  repository {
    repo_type                  = "TfsGit"
    repo_id                    = azuredevops_git_repository.demo_repo.0.id
    branch_name                = azuredevops_git_repository.demo_repo.0.default_branch
    yml_path                   = each.value
  }

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
    value                      = local.key_vault_name
  }

  for_each                     = local.pipeline_definitions
  depends_on                   = [
    azuredevops_git_repository_file.pipeline_yaml
  ]
}