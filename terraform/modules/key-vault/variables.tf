variable location {}
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