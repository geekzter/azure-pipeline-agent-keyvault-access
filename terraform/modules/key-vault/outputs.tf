output key_vault_id {
  value       = azurerm_key_vault.vault.id
}
output key_vault_name {
  value       = azurerm_key_vault.vault.name
}

output secret_names {
  value       = data.azurerm_key_vault_secrets.vault.names
}