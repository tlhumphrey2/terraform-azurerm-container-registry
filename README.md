# Azure Container Registry

This repo contains an example Terraform configuration that deploys an Azure Container Registry.
For more info, please see https://docs.microsoft.com/en-us/azure/container-registry/.

## Version compatibility

| Module version    | Terraform version | AzureRM version |
|-------------------|-------------------|-----------------|
| >= 1.x.x          | 0.13.x            | >= 2.3.0        |

## Example Usage
<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| azurerm | >= 2.30.0 |

## Providers

| Name | Version |
|------|---------|
| azuread | n/a |
| azurerm | >= 2.30.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ad\_groups | The ad groups of the resource. | `map(list(string))` | `{}` | no |
| admin\_enabled | Specifies whether the admin user is enabled. | `bool` | `true` | no |
| georeplication\_locations | A list of Azure locations where the container registry should be geo-replicated. The georeplication\_locations is only supported on new resources with the Premium SKU. | `list(string)` | `null` | no |
| location | Location for all resources | `string` | n/a | yes |
| names | Names to be applied to resources | `map(string)` | n/a | yes |
| resource\_group\_name | Resource group name | `string` | n/a | yes |
| sku | The SKU name of the container registry. Possible values are Basic, Standard and Premium | `string` | `"Basic"` | no |
| tags | Tags to be applied to resources | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| acr\_id | ID of azure container registry |
| acr\_name | Name of azure container registry |
| admin\_password | Password for azure container registry |
| admin\_username | Username for azure container registry |
| login\_server | Login server for azure container registry |

<!--- END_TF_DOCS --->

## Quick start

1.Install [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli).\
2.Sign into your [Azure Account](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli?view=azure-cli-latest)


```
# Login with the Azure CLI/bash terminal/powershell by running
az login

# Verify access by running
az account show --output jsonc

# Confirm you are running required/pinned version of terraform
terraform version
```

### Deploy the code

```
terraform init
terraform plan -out acr-01.tfplan
terraform apply acr-01.tfplan
```



