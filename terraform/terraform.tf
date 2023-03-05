terraform {
  required_providers {
    azuread                    = "~> 2.36"
    azuredevops = {
      source                   = "microsoft/azuredevops"
      version                  = "~> 0.3"
    }
    azurerm                    = "~> 3.39"
    cloudinit                  = "~> 2.2"
    http                       = "~> 2.2"
    local                      = "~> 2.3"
    random                     = "~> 3.4"
    time                       = "~> 0.9"
  }
  required_version             = "~> 1.3"
}

provider azuredevops {
  org_service_url              = local.devops_org_url
  personal_access_token        = var.devops_pat
}
provider azurerm {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
