##
# Required parameters
##

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  #default     = "tlh-rgTomboloDataLakeACR"
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
  default     = {
    market              = "hpccsystems"
    location            = "eastus2"
    environment         = "tlh"
    project             = "hpccsystems"
    business_unit       = "hpccsystems"
    product_group       = "hpccsystems"
    product_name        = "hpccsystems"
    subscription_id     = "us-hpccsystems-dev"
    subscription_type   = ""
    resource_group_type = ""
  }
}

variable "names" {
  description = "Names to be applied to resources"
  type        = map(string)
  default     = {
    market              = "hpccsystems"
    location            = "eastus2"
    environment         = "tlh"
    project             = "hpccsystems"
    business_unit       = "hpccsystems"
    product_group       = "hpccsystems"
    product_name        = "hpccsystems"
    subscription_id     = "us-hpccsystems-dev"
    subscription_type   = ""
    resource_group_type = ""
  }
}

variable "location" {
  description = "Location for all resources"
  type        = string
  default     = "eastus2"
}

##
# Optional parameters
##

######
# Sku
######
variable "sku" {
  description = "The SKU name of the container registry. Possible values are Basic, Standard and Premium"
  type        = string
  default     = "Basic"

  validation {
    condition     = can(regex("^(Basic|Standard|Premium)$", var.sku))
    error_message = "Invalid sku. Valid options are Basic, Standard and Premium."
  }
}

################
# Admin Enabled
################
variable "admin_enabled" {
  description = "Specifies whether the admin user is enabled."
  type        = bool
  default     = true
}

###########################
# Georeplication Locations
###########################
variable "georeplications" {
  description = "A list of Azure locations where the container registry should be geo-replicated. The georeplications is only supported on new resources with the Premium SKU."
  type = list(object({
    location = string
    tags     = map(string)
  }))
  default = null
}

variable "acr_readers" {
  description = "A map of friendly names to principal_ids to grant AcrPull permissions."
  type        = map(string)
  default     = {}
}

variable "acr_contributors" {
  description = "A map of friendly names to principal_ids to grant AcrPull and AcrPush permissions."
  type        = map(string)
  default     = {}
}

variable "acr_admins" {
  description = "A map of friendly names to principal_ids to grant AcrPull, AcrPush, AcrDelete and AcrImageSigner permissions."
  type        = map(string)
  default     = {}
}

variable "access_list" {
  description = "Map of CIDRs for ACR access."
  type        = map(string)
  default     = {}
}

variable "service_endpoints" {
  description = "Creates a virtual network rule in the subnet_id (values are virtual network subnet ids)."
  type        = map(string)
  default     = {}
}

variable "private_link" {
  description = "When defined, enables private link endpoint on the ACR"
  type = object({
    name                            = string
    private_service_connection_name = string
    subnet_id                       = string
  })
  default = null
}

################
# Override the random suffix
################
variable "disable_unique_suffix" {
  description = "Specifies whether the random 5 digit suffix should be NOT be used."
  type        = bool
  default     = false
}

