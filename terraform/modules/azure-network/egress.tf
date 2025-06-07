resource azurerm_nat_gateway egress {
  name                         = "${azurerm_virtual_network.pipeline_network.name}-natgw"
  location                     = var.location
  resource_group_name          = azurerm_virtual_network.pipeline_network.resource_group_name
  sku_name                     = "Standard"

  tags                         = var.tags
}

resource azurerm_public_ip nat_egress {
  name                         = "${azurerm_nat_gateway.egress.name}-ip"
  location                     = var.location
  resource_group_name          = azurerm_virtual_network.pipeline_network.resource_group_name
  allocation_method            = "Static"
  sku                          = "Standard"

  tags                         = var.tags
}

resource azurerm_monitor_diagnostic_setting nat_egress {
  name                         = "${azurerm_public_ip.nat_egress.name}-logs"
  target_resource_id           = azurerm_public_ip.nat_egress.id
  log_analytics_workspace_id   = var.log_analytics_workspace_resource_id

  enabled_log {
    category                   = "DDoSProtectionNotifications"
  }
  enabled_log {
    category                   = "DDoSMitigationFlowLogs"
  }
  enabled_log {
    category                   = "DDoSMitigationReports"
  }  

  enabled_metric {
    category                   = "AllMetrics"
  }
} 

resource azurerm_nat_gateway_public_ip_association egress {
  nat_gateway_id               = azurerm_nat_gateway.egress.id
  public_ip_address_id         = azurerm_public_ip.nat_egress.id
}

resource azurerm_subnet_nat_gateway_association self_hosted_agents {
  subnet_id                    = azurerm_subnet.self_hosted_agents.id
  nat_gateway_id               = azurerm_nat_gateway.egress.id

  depends_on                   = [
    azurerm_nat_gateway_public_ip_association.egress,
  ]
}