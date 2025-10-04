variable address_space {}
variable admin_cidr_ranges {
  type                         = list
  default                      = []
}
variable bastion_tags {
  description                  = "A map of the tags to use for the bastion resources that are deployed"
  type                         = map
} 
variable deploy_bastion {
  type                         = bool
}
variable diagnostics_storage_id {}
variable enable_public_access {
  type                         = bool
}
variable ip_tags {
    type                       = map
}
variable location {}
variable log_analytics_workspace_resource_id {}
variable resource_group_name {}
variable tags {
  type                         = map
}