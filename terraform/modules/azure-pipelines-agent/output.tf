output cloud_config {
  sensitive                    = true
  value                        = var.deploy_agent || var.prepare_host ? data.cloudinit_config.user_data.0.rendered : null
}
output identity_object_id {
  value                        = azurerm_linux_virtual_machine.linux_agent.identity.0.principal_id
}
output vm_id {
  value                        = azurerm_linux_virtual_machine.linux_agent.id
}
