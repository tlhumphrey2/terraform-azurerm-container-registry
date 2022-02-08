provider "azurerm" {
   features {}
}

resource "null_resource" "create_resource_group" {
  provisioner "local-exec" {
    command="az group create --name ${var.resource_group_name} --location ${var.location}"
  }
}

####################
# Container Registry
####################
resource "azurerm_container_registry" "acr" {
  name                = format("%s%scr%s", var.names.product_name, var.names.environment, var.disable_unique_suffix ? "" : random_string.suffix.result)
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  admin_enabled       = var.admin_enabled

  dynamic "georeplications" {
    for_each = var.georeplications == null ? [] : var.georeplications
    content {
      location = georeplications.value.location
      tags     = georeplications.value.tags
    }
  }

  dynamic "network_rule_set" {
    for_each = local.network_rule_set

    content {
      default_action = "Deny"

      dynamic "ip_rule" {
        for_each = network_rule_set.value.ip_rules
        iterator = ip_rule
        content {
          action   = "Allow"
          ip_range = ip_rule.value
        }
      }

      dynamic "virtual_network" {
        for_each = network_rule_set.value.virtual_networks
        iterator = subnet_id
        content {
          action    = "Allow"
          subnet_id = subnet_id.value
        }
      }
    }
  }
  tags = var.tags
  depends_on = [null_resource.create_resource_group]
}

resource "random_string" "suffix" {
  length  = 5
  special = false
}

resource "azurerm_role_definition" "acr" {
  for_each = local.roles

  name        = format("acr-%s-%s", azurerm_container_registry.acr.name, each.key)
  scope       = data.azurerm_subscription.current.id
  description = format("This is a custom %s role for the %s ACR.", each.key, azurerm_container_registry.acr.name)

  permissions {
    actions     = each.value
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.current.id
  ]
}

resource "azurerm_role_assignment" "acr" {
  for_each = local.role_assignments

  scope              = azurerm_container_registry.acr.id
  role_definition_id = azurerm_role_definition.acr[each.value.role].role_definition_resource_id
  principal_id       = each.value.id
}

resource "azurerm_private_endpoint" "acr-endpoint" {
  count = var.private_link == null ? 0 : 1

  name                = var.private_link.name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_link.subnet_id

  private_service_connection {
    name                           = var.private_link.private_service_connection_name
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }
}
