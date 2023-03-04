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

variable deploy_bastion {
  description                  = "Deploys managed bastion host"
  default                      = false
  type                         = bool
}

variable enable_public_access {
  type                         = bool
  default                      = false
}

variable devops_pat {
  description                  = "A Personal Access Token to access the Azure DevOps organization. Requires Agent Pools read & manage scope."
  nullable                     = false
}
variable devops_project {
  description                  = "The Azure DevOps project to authorize agent pools for. Requires 'Read & execute' permission on Build (queue a build) scope)"
  default                      = null
  nullable                     = true
}
variable devops_url {
  description                  = "The Azure DevOps organization url to join self-hosted agents to (default pool: 'Default', see linux_pipeline_agent_pool/windows_pipeline_agent_pool)"
  nullable                     = false
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

variable tags {
  description                  = "A map of the tags to use for the ARM resources that are deployed"
  type                         = map
  nullable                     = false

  default                      = {
  }  
} 

variable variable_group_variables {
  type                         = map
  default = {
    initial-variable1          = "test"
    # initial-variable2          = "test"
  }  
} 