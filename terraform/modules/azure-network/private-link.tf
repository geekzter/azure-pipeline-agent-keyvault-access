resource azurerm_private_dns_zone vault {
  name                         = "privatelink.vaultcore.azure.net"
  resource_group_name          = var.resource_group_name

  tags                         = var.tags
}

resource azurerm_private_dns_zone_virtual_network_link vault {
  name                         = "${azurerm_virtual_network.pipeline_network.name}-dns-vault"
  resource_group_name          = azurerm_virtual_network.pipeline_network.resource_group_name
  private_dns_zone_name        = azurerm_private_dns_zone.vault.name
  virtual_network_id           = azurerm_virtual_network.pipeline_network.id

  tags                         = var.tags
}

resource azurerm_subnet private_endpoint_subnet {
  name                         = "PrivateEndpointSubnet"
  virtual_network_name         = azurerm_virtual_network.pipeline_network.name
  resource_group_name          = azurerm_virtual_network.pipeline_network.resource_group_name
  address_prefixes             = [cidrsubnet(tolist(azurerm_virtual_network.pipeline_network.address_space)[0],4,5)]
  default_outbound_access_enabled = false
  private_endpoint_network_policies = "Enabled"

  depends_on                   = [
    azurerm_network_security_group.default
  ]
}

resource azurerm_private_dns_zone blob {
  name                         = "privatelink.blob.core.windows.net"
  resource_group_name          = var.resource_group_name

  tags                         = var.tags
}
resource azurerm_private_dns_zone_virtual_network_link blob {
  name                         = "${azurerm_virtual_network.pipeline_network.name}-dns-blob"
  resource_group_name          = azurerm_virtual_network.pipeline_network.resource_group_name
  private_dns_zone_name        = azurerm_private_dns_zone.blob.name
  virtual_network_id           = azurerm_virtual_network.pipeline_network.id

  tags                         = var.tags
}
resource azurerm_private_endpoint diag_blob_storage {
  name                         = "${local.diagnostics_storage_name}-endpoint"
  resource_group_name          = azurerm_virtual_network.pipeline_network.resource_group_name
  location                     = azurerm_virtual_network.pipeline_network.location
  
  subnet_id                    = azurerm_subnet.private_endpoint_subnet.id

  private_dns_zone_group {
    name                       = azurerm_private_dns_zone.blob.name
    private_dns_zone_ids       = [azurerm_private_dns_zone.blob.id]
  }
  
  private_service_connection {
    is_manual_connection       = false
    name                       = "${local.diagnostics_storage_name}-endpoint-connection"
    private_connection_resource_id = var.diagnostics_storage_id
    subresource_names          = ["blob"]
  }

  tags                         = var.tags
}
