data azuredevops_client_config current {}

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