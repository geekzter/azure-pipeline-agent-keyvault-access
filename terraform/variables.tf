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
