variable admin_cidr_ranges {
  type                         = list
  default                      = []
}
variable enable_public_access {
  type                         = bool
}
variable location {}
variable log_analytics_workspace_resource_id {}
variable private_endpoint_subnet_id {}
variable resource_group_name {}
variable secrets {
  type                         = map
} 
variable client_object_ids {
  type                        = list
}
variable tags {
  type                         = map
  nullable                     = false
  default                      = {}  
} 