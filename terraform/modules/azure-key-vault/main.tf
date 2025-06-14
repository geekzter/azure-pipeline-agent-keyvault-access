data azurerm_client_config current {}

resource azurerm_key_vault vault {
  name                         = var.name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  tenant_id                    = data.azurerm_client_config.current.tenant_id

  enable_rbac_authorization    = var.use_aad_rbac
  purge_protection_enabled     = false
  sku_name                     = "premium" # Required for VNet integration

  # Grant access to self
  dynamic access_policy {
    for_each = range(var.use_aad_rbac ? 0 : 1)
    content {
      tenant_id                = data.azurerm_client_config.current.tenant_id
      object_id                = data.azurerm_client_config.current.object_id

      secret_permissions       = [
                                  "Delete",
                                  "Get",
                                  "List",
                                  "Purge",
                                  "Set",
      ]
    }
  }

  dynamic access_policy {
    for_each                   = toset(var.use_aad_rbac ? [] : var.client_object_ids)
    content {
      tenant_id                = data.azurerm_client_config.current.tenant_id
      object_id                = access_policy.value

      secret_permissions       = [
                                "Get",
                                "List"
      ]
    }
  }  

  dynamic network_acls {
    for_each = range(var.enable_public_access ? 0 : 1)
    content {
      default_action           = "Deny"
      bypass                   = "None" # Azure DevOps is not included in 'AzureServices'
      ip_rules                 = var.allow_cidr_ranges
    }
  }

  tags                         = var.tags
}

resource azurerm_monitor_diagnostic_setting key_vault {
  name                         = "${azurerm_key_vault.vault.name}-logs"
  target_resource_id           = azurerm_key_vault.vault.id
  log_analytics_workspace_id   = var.log_analytics_workspace_resource_id

  enabled_log {
    category                   = "AuditEvent"
  }

  enabled_metric {
    category                   = "AllMetrics"
  }
}

resource azurerm_key_vault_secret initial_variable {
  name                         = each.key
  value                        = each.value
  key_vault_id                 = azurerm_key_vault.vault.id

  for_each                     = var.secrets
}

resource random_string secret {
  length                       = 32
  upper                        = true
  lower                        = true
  numeric                      = true
  special                      = true
  override_special             = "" 

  count                        = var.generate_secrets
}

resource azurerm_key_vault_secret generated {
  name                         = "generated-secret-${count.index}"
  value                        = random_string.secret[count.index].result
  key_vault_id                 = azurerm_key_vault.vault.id

  count                        = var.generate_secrets
}

data azurerm_key_vault_secrets vault {
  key_vault_id                 = azurerm_key_vault.vault.id

  depends_on                   = [
    azurerm_key_vault.vault,
    azurerm_key_vault_secret.generated,
    azurerm_key_vault_secret.initial_variable,
  ]
}
