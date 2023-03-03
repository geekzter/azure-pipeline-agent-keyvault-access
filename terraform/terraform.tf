terraform {
  required_providers {
    azuread                    = "~> 2.36"
    azuredevops = {
      source                   = "microsoft/azuredevops"
      version                  = "~> 0.3"
    }
    azurerm                    = "~> 3.39"
    local                      = "~> 2.3"
    random                     = "~> 3.4"
    time                       = "~> 0.9"
  }
  required_version             = "~> 1.3"
}

provider azuredevops {
  org_service_url              = local.devops_url
  personal_access_token        = var.devops_pat
}
provider azurerm {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

data azurerm_client_config default {}
data azurerm_subscription default {}