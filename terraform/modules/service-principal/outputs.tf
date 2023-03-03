output application_id {
  value       = azuread_application.app_registration.application_id
}
output object_id {
  value       = azuread_application.app_registration.id
}
output principal_id {
  value       = azuread_service_principal.spn.object_id
}
output secret {
  sensitive   = true
  value       = azuread_service_principal_password.spnsecret.value
}