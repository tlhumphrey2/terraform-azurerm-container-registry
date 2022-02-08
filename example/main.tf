terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.61, !=2.62"
    }
  }
  required_version = ">= 0.14.8"
}

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

resource "random_string" "random" {
  length  = 12
  upper   = false
  number  = false
  special = false
}

module "subscription" {
  source = "github.com/Azure-Terraform/terraform-azurerm-subscription-data.git?ref=v1.0.0"
  subscription_id = data.azurerm_subscription.current.subscription_id
}

module "naming" {
  source = "github.com/Azure-Terraform/example-naming-template.git?ref=v1.0.0"
}

module "metadata" {
  source = "github.com/Azure-Terraform/terraform-azurerm-metadata.git?ref=v1.5.0"

  naming_rules = module.naming.yaml

  market              = "us"
  project             = "https://github.com/Azure-Terraform/terraform-azurerm-virtual-network/tree/master/example/bastion"
  location            = "eastus2"
  environment         = "sandbox"
  product_name        = random_string.random.result
  business_unit       = "infra"
  product_group       = "contoso"
  subscription_id     = module.subscription.output.subscription_id
  subscription_type   = "dev"
  resource_group_type = "app"
}

module "resource_group" {
  source = "github.com/Azure-Terraform/terraform-azurerm-resource-group.git?ref=v1.0.0"

  location = module.metadata.location
  names    = module.metadata.names
  tags     = module.metadata.tags
}

module "virtual_network" {
  source = "github.com/Azure-Terraform/terraform-azurerm-virtual-network.git?ref=v2.6.0"

  naming_rules = module.naming.yaml

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  names               = module.metadata.names
  tags                = module.metadata.tags

  address_space = ["10.1.1.0/24"]

  subnets = {
    iaas-outbound = {
      cidrs                                          = ["10.1.1.0/27"]
      service_endpoints                              = ["Microsoft.ContainerRegistry"]
      enforce_private_link_endpoint_network_policies = true
    }
  }
}

module "azurerm_kubernetes_cluster" {
  source = "git@github.com:/Azure-Terraform/terraform-azurerm-kubernetes.git?ref=v3.2.2"

  names                    = module.metadata.names
  location                 = module.metadata.location
  resource_group_name      = module.resource_group.name
  tags                     = module.metadata.tags

  node_pool_subnets        = {
    private = { 
      id = module.virtual_network.subnets["iaas-outbound"].id
      resource_group_name = module.resource_group.name, 
      network_security_group_name = module.virtual_network.subnet_nsg_names["iaas-outbound"] 
    } 
  }  
} 

# Create a Azure Container Registry
module "acr" {
  source  = "../"

  location                 = module.metadata.location
  resource_group_name      = module.resource_group.name
  names                    = module.metadata.names
  tags                     = module.metadata.tags

  sku                      = "Premium"

  georeplications = [
    {
      location = "CentralUS"
      tags     = { "purpose" =  "Primary DR Region" }
    }
  ]
  admin_enabled            = true
  acr_contributors = { aks = module.azurerm_kubernetes_cluster.kubelet_identity.object_id }

  service_endpoints = {
    "iaas-outbound" = module.virtual_network.subnets["iaas-outbound"].id
  }
}