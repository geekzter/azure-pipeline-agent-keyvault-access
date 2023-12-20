variable application_name {
  description                  = "Value of 'application' resource tag"
  default                      = "Key Vault Variable Group"
  nullable                     = false
}
variable application_owner {
  description                  = "Value of 'owner' resource tag"
  default                      = "" # Empty string takes objectId of current user
  nullable                     = false
}

variable azdo_geography {
  description                  = "The geography the Azure DevOps organization is in (see https://learn.microsoft.com/azure/devops/organizations/security/allow-list-ip-url?view=azure-devops&tabs=IP-V4#inbound-connections)"
  default                      = null # null means all geographies
  type                         = string
  validation {
    condition                  = contains(
      [
        "asiapacific",
        "australia", 
        "brazil", 
        "canada", 
        "europe",
        "india",
        "uk",
        "us",
        "expressroute"
      ],
      coalesce(var.azdo_geography,"expressroute")
    )
    error_message              = "geography is not a valid Azure DevOps geography"
  }
}
variable azdo_project {
  description                  = "The Azure DevOps project to authorize agent pools for. Requires 'Read & execute' permission on Build (queue a build) scope)"
  default                      = null
  nullable                     = true
  type                         = string
}
variable azdo_org_url {
  description                  = "The Azure DevOps organization url to join self-hosted agents to (default pool: 'Default', see linux_pipeline_agent_pool/windows_pipeline_agent_pool)"
  nullable                     = false
}
variable azdo_variable_group_variables {
  type                         = map
  default = {
    initial-variable1          = "test"
  }  
} 
variable azdo_variable_group_variables_to_generate {
  default                      = 1
  description                  = "Generate variables for testing purposes"
  type                         = number
}

variable azure_agent_linux_tools {
  default                      = false
  type                         = bool
}
variable azure_agent_linux_os_image_id {
  default                      = null
}
# az vm image list-offers -l centralus -p "Canonical" -o table
variable azure_agent_linux_os_offer {
  default                      = "0001-com-ubuntu-server-jammy"
}
variable azure_agent_linux_os_publisher {
  default                      = "Canonical"
}
# az vm image list-skus -l centralus -f "0001-com-ubuntu-server-jammy" -p "Canonical" -o table
variable azure_agent_linux_os_sku {
  default                      = "22_04-lts"
}
variable azure_agent_linux_os_version {
  default                      = "latest"
}
variable azure_agent_linux_storage_type {
  default                      = "Standard_LRS"
}
variable azure_agent_linux_vm_size {
  default                      = "Standard_D2s_v3"
}
variable azure_agent_ssh_private_key {
  default                      = "~/.ssh/id_rsa"
}
variable azure_agent_ssh_public_key {
  default                      = "~/.ssh/id_rsa.pub"
}
variable azure_agent_user_name {
  default                      = "devopsadmin"
}

variable azure_bastion_tags {
  description                  = "A map of the tags to use for the bastion resources that are deployed"
  type                         = map

  default                      = {}  
  nullable                     = false
} 
variable azure_location {
  default                      = "westeurope"
  nullable                     = false
}
variable azure_log_analytics_workspace_id {
  description                  = "Specify a pre-existing Log Analytics workspace"
  default                      = ""
}
variable azure_tags {
  description                  = "A map of the tags to use for the ARM resources that are deployed"
  type                         = map
  nullable                     = false

  default                      = {
  }  
} 

variable create_agent {
  description                  = "Deploys self-hosted Linux agent"
  default                      = true
  type                         = bool
}

# Switches that determine what infrastucture components are provisioned
variable create_azdo_pipeline {
  description                  = "Creates Azure Pipeline with YAML definition. Requires create_azdo_resources to be true"
  default                      = true
  type                         = bool
}
variable create_azdo_resources {
  description                  = "Creates Azure DevOps project with Variable Group & Pipeline"
  default                      = true
  type                         = bool
}
variable create_azure_bastion {
  description                  = "Deploys managed bastion host"
  default                      = false
  type                         = bool
}
variable create_entra_federation {
  description                  = "Use Workload identity federation (OIDC) to authenticate the Variable Group Service Connection"
  default                      = true
  type                         = bool
}
variable enable_azure_key_vault_public_access {
  type                         = bool
  default                      = false
}

variable owner_object_id {
  default                      = null
}

variable prepare_host {
  type                         = bool
  default                      = true
}

variable resource_prefix {
  description                  = "The prefix to put at the end of resource names created"
  default                      = "demo"
  nullable                     = false
}
variable resource_suffix {
  description                  = "The suffix to put at the start of resource names created"
  default                      = null # Empty string triggers a random suffix
  nullable                     = true
}

variable run_id {
  description                  = "The ID that identifies the pipeline / workflow that invoked Terraform"
  default                      = ""
  nullable                     = true
}

variable shutdown_time {
  default                      = "" # Empty string doesn't triggers a shutdown
  description                  = "Time the self-hosyted will be stopped daily. Setting this to null or an empty string disables auto shutdown."
}

variable timezone {
  default                      = "W. Europe Standard Time"
}

variable use_azure_key_vault_aad_rbac {
  description                  = "Whether to use Key Vault AAD RBAC to grant access to the Key Vault, or use access policies instead"
  type                         = bool
  default                      = false
}