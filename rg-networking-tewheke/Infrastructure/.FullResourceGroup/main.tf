/**************************************************
New Resources
***************************************************/
// Create RG if it does not already exist
resource "azurerm_resource_group" "resourceGroup" {
  name = "${var.resourceGroupName}-${var.resourceSuffix}-${var.environment}-${var.locationSuffix}"
  location = var.location
}

/**************************************************
Module Calls
***************************************************/
module "nsg" {
  source         = "./NetworkSecurityGroup"
  location       = var.location
  locationSuffix = var.locationSuffix
  resourceSuffix = var.resourceSuffix
  environment    = var.environment

  depends_on = [ azurerm_resource_group.resourceGroup ]
}

module "vnet" {
  source                             = "./VirtualNetwork"
  location       = var.location
  locationSuffix = var.locationSuffix
  resourceSuffix = var.resourceSuffix
  environment    = var.environment
  integrationVNETAddressSpace        = var.integrationVNETAddressSpace
  appGatewaySubnetAddressPrefix      = var.appGatewaySubnetAddressPrefix
  gitHubRunnersSubnetAddressPrefix   = var.gitHubRunnersSubnetAddressPrefix
  apimSubnetAddressPrefix            = var.apimSubnetAddressPrefix
  privateEndpointSubnetAddressPrefix = var.privateEndpointSubnetAddressPrefix
  appsSubnetAddressPrefix            = var.appsSubnetAddressPrefix

  depends_on = [ module.nsg ]
}

module "private_dns_zone" {
  source         = "./PrivateDNSZone"
  location       = var.location
  locationSuffix = var.locationSuffix
  resourceSuffix = var.resourceSuffix
  environment    = var.environment

  depends_on = [ module.vnet ]
}

// Always do App Gateway seperate as it requires things from shared infra i.e. KeyVault and APIM
# module "app_gateway" {
#   source                        = "./Application Gateway"
#   resourceSuffix                = var.resourceSuffix
#   environment                   = var.environment
#   location                      = var.location
#   appGatewayFqdn                = var.appGatewayFqdn
# }
