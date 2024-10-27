locals {
  scale_set_agent_address_prefixes = [cidrsubnet(tolist(azurerm_virtual_network.pipeline_network.address_space)[0],4,8)]  
  self_hosted_agent_address_prefixes = [cidrsubnet(tolist(azurerm_virtual_network.pipeline_network.address_space)[0],4,9)]  
}

resource azurerm_subnet self_hosted_agents {
  name                         = "SelfHostedAgents"
  virtual_network_name         = azurerm_virtual_network.pipeline_network.name
  resource_group_name          = azurerm_virtual_network.pipeline_network.resource_group_name
  address_prefixes             = local.self_hosted_agent_address_prefixes
  depends_on                   = [
    azurerm_network_security_rule.agent_rdp,
    azurerm_network_security_rule.agent_ssh,
  ]
}

resource azurerm_network_security_group agent_nsg {
  name                         = "${azurerm_virtual_network.pipeline_network.name}-agent-nsg"
  location                     = var.location
  resource_group_name          = azurerm_virtual_network.pipeline_network.resource_group_name

  tags                         = var.tags
}
resource azurerm_network_security_rule agent_ssh {
  name                         = "AllowSSH"
  priority                     = 201
  direction                    = "Inbound"
  access                       = var.enable_public_access ? "Allow" : "Deny"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "22"
  source_address_prefixes      = var.admin_cidr_ranges
  destination_address_prefixes = concat(local.scale_set_agent_address_prefixes,local.self_hosted_agent_address_prefixes)
  resource_group_name          = azurerm_network_security_group.agent_nsg.resource_group_name
  network_security_group_name  = azurerm_network_security_group.agent_nsg.name
}
resource azurerm_network_security_rule agent_rdp {
  name                         = "AllowRDP"
  priority                     = 202
  direction                    = "Inbound"
  access                       = var.enable_public_access ? "Allow" : "Deny"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "3389"
  source_address_prefixes      = var.admin_cidr_ranges
  destination_address_prefixes = concat(local.scale_set_agent_address_prefixes,local.self_hosted_agent_address_prefixes)
  resource_group_name          = azurerm_network_security_group.agent_nsg.resource_group_name
  network_security_group_name  = azurerm_network_security_group.agent_nsg.name
}
