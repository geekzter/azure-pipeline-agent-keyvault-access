output agent_address_range {
  value                        = azurerm_subnet.self_hosted_agents.address_prefixes[0]
}

output bastion_id {
  value                        = var.deploy_bastion ? azurerm_bastion_host.bastion.0.id : null
}
output bastion_name {
  value                        = var.deploy_bastion ? azurerm_bastion_host.bastion.0.name : null
}

output private_endpoint_subnet_id {
  value                        = azurerm_subnet.private_endpoint_subnet.id
}

output azurerm_private_dns_zone_vault_id {
  value                        = azurerm_private_dns_zone.vault.id
}
output azurerm_private_dns_zone_vault_name {
  value                        = azurerm_private_dns_zone.vault.name
}

output self_hosted_agents_subnet_id {
  value                        = azurerm_subnet.self_hosted_agents.id
}
output outbound_ip_address {
  value                        = azurerm_public_ip.nat_egress.ip_address
}
output virtual_network_id {
  value                        = azurerm_virtual_network.pipeline_network.id
}