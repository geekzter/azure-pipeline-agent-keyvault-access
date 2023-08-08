terraform {
  required_providers {
    azuread                    = "= 2.36.0"
    azuredevops = {
      source                   = "microsoft/azuredevops"
      version                  = "~> 0.3"
    }
    azurerm                    = "~> 3.39"
    cloudinit                  = "~> 2.2"
    external                   = "~> 2.3"
    http                       = "~> 2.2"
    local                      = "~> 2.3"
    random                     = "~> 3.4"
    time                       = "~> 0.9"
  }
  required_version             = "~> 1.3"
}

data external azdo_token {
  program                      = [
    "az", "account", "get-access-token", 
    "--resource", "499b84ac-1321-427f-aa17-267ca6975798", # Azure DevOps
    "-o","json"
  ]
}
provider azuredevops {
  org_service_url              = local.devops_org_url
  personal_access_token        = data.external.azdo_token.result.accessToken
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
