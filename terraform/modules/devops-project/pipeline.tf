locals {
  pipeline_definitions         = {
    service-connection-info    = "azure-service-connection-info.yml"
  }
}

resource azuredevops_git_repository_file pipeline_yaml {
  repository_id                = azuredevops_git_repository.demo_repo.id
  file                         = each.value
  content                      = file("${path.root}/../pipelines/${each.value}")
  branch                       = "refs/heads/main"
  commit_message               = "Pipeline YAML file, commit from Terraform"
  overwrite_on_create          = false

  for_each                     = local.pipeline_definitions
}

resource azuredevops_build_definition pipeline {
  project_id                   = azuredevops_project.demo_project.id
  name                         = each.key

  ci_trigger {
    use_yaml                   = true
  }

  repository {
    repo_type                  = "TfsGit"
    repo_id                    = azuredevops_git_repository.demo_repo.id
    branch_name                = azuredevops_git_repository.demo_repo.default_branch
    yml_path                   = each.value
  }

  variable_groups              = [
    azuredevops_variable_group.key_vault_variable_group.id
  ]

  variable {
    name                       = "serviceConnectionName"
    value                      = azuredevops_serviceendpoint_azurerm.service_connection.service_endpoint_name
  }

  for_each                     = local.pipeline_definitions
}