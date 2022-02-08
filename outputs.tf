output "login_server" {
  value       = azurerm_container_registry.acr.login_server
  description = "Login server for azure container registry"
}

output "admin_username" {
  value       = azurerm_container_registry.acr.admin_username
  description = "Username for azure container registry"
}

output "admin_password" {
  value       = azurerm_container_registry.acr.admin_password
  description = "Password for azure container registry"
  sensitive   = true
}

output "acr_name" {
  value       = azurerm_container_registry.acr.name
  description = "Name of azure container registry"
}

output "acr_id" {
  value       = azurerm_container_registry.acr.id
  description = "ID of azure container registry"
}
