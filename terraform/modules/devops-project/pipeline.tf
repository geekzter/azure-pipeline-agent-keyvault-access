resource azuredevops_git_repository_file pipeline_yaml {
  repository_id                = azuredevops_git_repository.demo_repo.id
  file                         = "azure-service-connection-info.yml"
  content                      = file("${path.root}/../pipelines/azure-service-connection-info.yml")
  branch                       = "refs/heads/main"
  commit_message               = "Pipeline YAML file, commit from Terraform"
  overwrite_on_create          = false
}

resource azuredevops_build_definition service_connection_info {
  project_id                   = azuredevops_project.demo_project.id
  name                         = "service-connection-info"

  ci_trigger {
    use_yaml                   = true
  }

  repository {
    repo_type                  = "TfsGit"
    repo_id                    = azuredevops_git_repository.demo_repo.id
    branch_name                = azuredevops_git_repository.demo_repo.default_branch
    yml_path                   = azuredevops_git_repository_file.pipeline_yaml.file
  }

  variable_groups              = [
    azuredevops_variable_group.key_vault_variable_group.id
  ]
}