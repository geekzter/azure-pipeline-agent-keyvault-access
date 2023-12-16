data azuredevops_client_config current {}

resource azuredevops_git_repository demo_repo {
  project_id                   = var.project_id
  name                         = "keyvault-pipelines-${terraform.workspace}-${var.suffix}"
  default_branch               = "refs/heads/main"
  initialization {
    init_type                  = "Clean"
  }

  count                        = var.create_pipeline ? 1 : 0
}