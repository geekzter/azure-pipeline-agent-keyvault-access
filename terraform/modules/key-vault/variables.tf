variable location {}
variable log_analytics_workspace_resource_id {}
variable resource_group_name {}
variable secrets {
  type                         = map
} 
variable service_principal_object_id {}
variable tags {
  type                         = map
  nullable                     = false
  default                      = {}  
} 