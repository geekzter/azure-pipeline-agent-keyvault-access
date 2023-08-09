data azuread_client_config current {}

resource azuread_application app_registration {
  display_name                 = var.name
  owners                       = [var.owner_object_id]
}


resource azuread_application_password secret {
  rotate_when_changed          = {
    rotation                   = timeadd(time_rotating.secret_expiration.id, "8760h") # One year from now
  }

  application_object_id         = azuread_application.app_registration.id
}

resource azuread_service_principal spn {
  application_id               = azuread_application.app_registration.application_id
  owners                       = [var.owner_object_id]
}

resource time_rotating secret_expiration {
  rotation_years               = 1
}
