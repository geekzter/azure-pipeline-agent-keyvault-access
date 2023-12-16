variable allow_ip_ranges {
  default                      = [
    # Public inbound connections from Azure DevOps originate from these ranges
    # https://learn.microsoft.com/azure/devops/organizations/security/allow-list-ip-url?view=azure-devops&tabs=IP-V4#inbound-connections
    "20.37.194.0/24",    # Australia East
    "20.42.226.0/24",    # Australia South East

    "191.235.226.0/24",  # Brazil South

    "52.228.82.0/24",    # Central Canada

    "20.195.68.0/24",    # Southeast Asia

    "20.41.194.0/24",    # South India
    "20.204.197.192/26", # Central India

    "20.37.158.0/23",    # Central US
    "52.150.138.0/24",   # West Central US
    "40.80.187.0/24",    # North Central US
    "40.119.10.0/24",    # South Central US
    "20.42.5.0/24",      # East US
    "20.41.6.0/23",      # East 2 US
    "40.80.187.0/24",    # North US
    "40.119.10.0/24",    # South US
    "40.82.252.0/24",    # West US
    "20.42.134.0/23",    # West 2 US
    "20.125.155.0/24",   # West 3 US

    "40.74.28.0/23",     # West Europe
    "20.166.41.0/24",    # North Europe
    "51.104.26.0/24",    # UK South

    # ExpressRoute connections
    # https://learn.microsoft.com/azure/devops/organizations/security/allow-list-ip-url?view=azure-devops&tabs=IP-V4#azure-devops-expressroute-connections
    "13.107.6.175/32",
    "13.107.6.176/32",
    "13.107.6.183/32",
    "13.107.9.175/32",
    "13.107.9.176/32",
    "13.107.9.183/32",
    "13.107.42.18/32",
    "13.107.42.19/32",
    "13.107.42.20/32",
    "13.107.43.18/32",
    "13.107.43.19/32",
    "13.107.43.20/32",
  ]
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

variable create_federation {
  description                  = "Use Workload identity federatin (OIDC) to authenticate the Variable Group Service Connection"
  default                      = true
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
  default                      = false
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
  default                      = "0001-com-ubuntu-server-jammy"
}
variable linux_os_publisher {
  default                      = "Canonical"
}
# az vm image list-skus -l centralus -f "0001-com-ubuntu-server-jammy" -p "Canonical" -o table
variable linux_os_sku {
  default                      = "22_04-lts"
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