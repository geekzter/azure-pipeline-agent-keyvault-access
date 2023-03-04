data azuread_client_config current {}

resource azurerm_key_vault vault {
  name                         = substr(lower(replace("${var.resource_group_name}-vlt","/-|a|e|i|o|u|y/","")),0,24)
  location                     = var.location
  resource_group_name          = var.resource_group_name
  tenant_id                    = data.azuread_client_config.current.tenant_id

  enabled_for_disk_encryption  = true
  purge_protection_enabled     = false
  sku_name                     = "premium" # Required for VNet integration

  # Grant access to self
  access_policy {
    tenant_id                  = data.azuread_client_config.current.tenant_id
    object_id                  = data.azuread_client_config.current.object_id

    key_permissions            = [
                                "Create",
                                "Delete",
                                "Get",
                                "List",
                                "Purge",
                                "Recover",
                                "UnwrapKey",
                                "WrapKey",
    ]
    secret_permissions         = [
                                "Delete",
                                "Get",
                                "List",
                                "Purge",
                                "Set",
    ]
  }

  # Grant access to Service Principal
  access_policy {
    tenant_id                  = data.azuread_client_config.current.tenant_id
    object_id                  = var.service_principal_object_id

    secret_permissions         = [
                                "Get",
                                "List"
    ]
  }

  network_acls {
    default_action             = var.enable_public_access ? "Allow" : "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = var.admin_cidr_ranges
  }
  public_network_access_enabled= var.enable_public_access

  tags                         = var.tags
}

resource azurerm_monitor_diagnostic_setting key_vault {
  name                         = "${azurerm_key_vault.vault.name}-logs"
  target_resource_id           = azurerm_key_vault.vault.id
  log_analytics_workspace_id   = var.log_analytics_workspace_resource_id

  enabled_log {
    category                   = "AuditEvent"

    retention_policy {
      enabled                  = false
    }
  }

  metric {
    category                   = "AllMetrics"

    retention_policy {
      enabled                  = false
    }
  }
}

resource azurerm_role_assignment service_principal_reader {
  scope                        = azurerm_key_vault.vault.id
  role_definition_name         = "Reader"
  principal_id                 = var.service_principal_object_id
}

resource azurerm_key_vault_secret initial_variable {
  name                         = each.key
  value                        = each.value
  key_vault_id                 = azurerm_key_vault.vault.id

  for_each                     = var.secrets
}

data azurerm_key_vault_secrets vault {
  key_vault_id                 = azurerm_key_vault.vault.id

  depends_on                   = [
    azurerm_key_vault.vault,
    azurerm_key_vault_secret.initial_variable,
    azurerm_role_assignment.service_principal_reader
  ]
}