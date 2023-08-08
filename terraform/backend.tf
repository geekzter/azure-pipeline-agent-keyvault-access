terraform {
  backend "azurerm" {
    # resource_group_name        = "Automation"
    resource_group_name        = "ericvan-common"
    # storage_account_name       = "ewterraformstate"
    storage_account_name       = "ericvantfstore"
    container_name             = "azdokeyvault" 
    key                        = "terraform.tfstate"
    sas_token                  = "sp=racwl&st=2023-08-08T09:22:29Z&se=2023-08-08T17:22:29Z&spr=https&sv=2022-11-02&sr=c&sig=vdA0Nqd9Nm8otaZIasFBuc7U1lZ7KJpmifzUehkCQkw%3D"
  }
}
