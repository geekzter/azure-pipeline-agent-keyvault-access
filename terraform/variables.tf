variable admin_ip_ranges {
  default                      = []
  type                         = list
}

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

variable bastion_tags {
  description                  = "A map of the tags to use for the bastion resources that are deployed"
  type                         = map

  default                      = {}  
  nullable                     = false
} 

variable create_agent {
  description                  = "Deploys self-hosted Linux agent"
  default                      = true
  type                         = bool
}

variable create_bastion {
  description                  = "Deploys managed bastion host"
  default                      = false
  type                         = bool
}

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

variable enable_public_access {
  type                         = bool
  default                      = true
}

variable devops_project {
  description                  = "The Azure DevOps project to authorize agent pools for. Requires 'Read & execute' permission on Build (queue a build) scope)"
  default                      = null
  nullable                     = true
  type                         = string
}
variable devops_org_url {
  description                  = "The Azure DevOps organization url to join self-hosted agents to (default pool: 'Default', see linux_pipeline_agent_pool/windows_pipeline_agent_pool)"
  nullable                     = false
}

variable linux_tools {
  default                      = false
  type                         = bool
}

variable linux_os_image_id {
  default                      = null
}
# az vm image list-offers -l centralus -p "Canonical" -o table
variable linux_os_offer {
  default                      = "0001-com-ubuntu-server-focal"
}
variable linux_os_publisher {
  default                      = "Canonical"
}
# az vm image list-skus -l centralus -f "0001-com-ubuntu-server-focal" -p "Canonical" -o table
variable linux_os_sku {
  default                      = "20_04-lts"
}
variable linux_os_version {
  default                      = "latest"
}
variable linux_storage_type {
  default                      = "Standard_LRS"
}
variable linux_vm_size {
  default                      = "Standard_D2s_v3"
}

variable location {
  default                      = "westeurope"
  nullable                     = false
}

variable log_analytics_workspace_id {
  description                  = "Specify a pre-existing Log Analytics workspace. The workspace needs to have the Security, SecurityCenterFree, ServiceMap, Updates, VMInsights solutions provisioned"
  default                      = ""
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

variable ssh_private_key {
  default                      = "~/.ssh/id_rsa"
}
variable ssh_public_key {
  default                      = "~/.ssh/id_rsa.pub"
}

variable tags {
  description                  = "A map of the tags to use for the ARM resources that are deployed"
  type                         = map
  nullable                     = false

  default                      = {
  }  
} 

variable timezone {
  default                      = "W. Europe Standard Time"
}

variable use_key_vault_aad_rbac {
  description                  = "Whether to use Key Vault AAD RBAC to grant access to the Key Vault, or use access policies instead"
  type                         = bool
  default                      = false
}

variable user_name {
  default                      = "devopsadmin"
}

variable variable_group_variables_to_generate {
  default                      = 1
  type                         = number
}

variable variable_group_variables {
  type                         = map
  default = {
    initial-variable1          = "test"
    # initial-variable2          = "test"
  }  
} 