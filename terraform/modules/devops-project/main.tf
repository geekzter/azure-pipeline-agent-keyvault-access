data azuredevops_client_config current {}

locals {
  project_id                    = var.create_project ? azuredevops_project.demo_project.0.id : data.azuredevops_project.existing_project.0.id
  project_name                  = var.create_project ? azuredevops_project.demo_project.0.name : data.azuredevops_project.existing_project.0.name
}

data azuredevops_project existing_project {
  name                         = var.name

  count                        = var.create_project ? 0 : 1
}

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
    repositories               = "enabled"
    testplans                  = "disabled"
  }

  count                        = var.create_project ? 1 : 0
}

resource azuredevops_git_repository demo_repo {
  project_id                   = local.project_id
  name                         = var.repo_name
  default_branch               = "refs/heads/main"
  initialization {
    init_type                  = "Clean"
  }

  count                        = var.create_pipeline ? 1 : 0
}