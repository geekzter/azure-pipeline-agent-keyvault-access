variable allow_cidr_ranges {
  type                         = list
  default                      = []
}
variable client_object_ids {
  type                        = list
}
variable configure_private_link {
  type                        = bool
}
variable enable_public_access {
  type                         = bool
}
variable generate_secrets {
  type                         = number
}
variable location {}
variable log_analytics_workspace_resource_id {}
variable name {}
variable private_endpoint_subnet_id {}
variable resource_group_name {}
variable secrets {
  type                         = map
} 
variable tags {
  type                         = map
  nullable                     = false
  default                      = {}  
} 
variable use_aad_rbac {
  type                         = bool
}