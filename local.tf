locals {
  role_definitions = {
    reader = ["Microsoft.ContainerRegistry/registries/pull/read"]

    contributor = ["Microsoft.ContainerRegistry/registries/pull/read",
    "Microsoft.ContainerRegistry/registries/push/write"]

    admin = ["Microsoft.ContainerRegistry/registries/pull/read",
      "Microsoft.ContainerRegistry/registries/push/write",
      "Microsoft.ContainerRegistry/registries/artifacts/delete",
    "Microsoft.ContainerRegistry/registries/sign/write"]
  }

  active_roles = compact([
    (length(var.acr_readers) > 0 ? "reader" : ""),
    (length(var.acr_contributors) > 0 ? "contributor" : ""),
    (length(var.acr_admins) > 0 ? "admin" : ""),
  ])

  roles = { for role in local.active_roles : role => local.role_definitions[role] }

  role_assignments = merge(
    { for k, v in var.acr_readers : "reader.${k}" => { id = v, role = "reader" } },
    { for k, v in var.acr_contributors : "contributor.${k}" => { id = v, role = "contributor" } },
    { for k, v in var.acr_admins : "admin.${k}" => { id = v, role = "admin" } }
  )

  network_rule_set = (((length(var.access_list) > 0) || (length(var.service_endpoints) > 0)) ?
  { enabled = { ip_rules = var.access_list, virtual_networks = var.service_endpoints } } : {})

  valid_sku_geo = (((var.georeplications != null) && (var.sku != "Premium")) ?
  file("ERROR: georeplications require Premium SKU") : null)

  valid_sku_access_list = (((length(var.access_list) > 0) && (var.sku != "Premium")) ?
  file("ERROR: access_list requires Premium SKU") : null)

  valid_sku_service_endpoints = (((length(var.service_endpoints) > 0) && (var.sku != "Premium")) ?
  file("ERROR: service endpoints require Premium SKU") : null)
}