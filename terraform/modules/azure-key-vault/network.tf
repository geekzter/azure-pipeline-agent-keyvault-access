resource azurerm_private_endpoint vault_endpoint {
  name                         = "${azurerm_key_vault.vault.name}-endpoint"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  
  subnet_id                    = var.private_endpoint_subnet_id

  private_service_connection {
    is_manual_connection       = false
    name                       = "${azurerm_key_vault.vault.name}-endpoint-connection"
    private_connection_resource_id = azurerm_key_vault.vault.id
    subresource_names          = ["vault"]
  }

  tags                         = var.tags

  count                        = var.configure_private_link ? 1 : 0
}
resource azurerm_private_dns_a_record vault_dns_record {
  name                         = azurerm_key_vault.vault.name
  zone_name                    = "privatelink.vaultcore.azure.net"
  resource_group_name          = var.resource_group_name
  ttl                          = 300
  records                      = [azurerm_private_endpoint.vault_endpoint.0.private_service_connection[0].private_ip_address]

  tags                         = var.tags

  count                        = var.configure_private_link ? 1 : 0
}