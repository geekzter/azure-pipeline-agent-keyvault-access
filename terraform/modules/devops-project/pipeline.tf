resource azuredevops_git_repository_file pipeline_yaml {
  repository_id                = azuredevops_git_repository.demo_repo.id
  file                         = "azure-service-connection-info.yml"
  content                      = file("${path.root}/../pipelines/azure-service-connection-info.yml")
  branch                       = "refs/heads/main"
  commit_message               = "Pipeline YAML file, commit from Terraform"
  overwrite_on_create          = false
}
