terraform {
  required_providers {
    azuread                    = "~> 2.36"
    azuredevops = {
      source                   = "microsoft/azuredevops"
      version                  = "~> 1.0"
    }
    azurerm                    = "~> 4.6"
    cloudinit                  = "~> 2.2"
    external                   = "~> 2.3"
    http                       = "~> 3.4"
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
    "--query","{accessToken:accessToken}",
    "-o","json"
  ]
}
provider azuredevops {
  org_service_url              = local.azdo_org_url
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
  storage_use_azuread          = true
}
