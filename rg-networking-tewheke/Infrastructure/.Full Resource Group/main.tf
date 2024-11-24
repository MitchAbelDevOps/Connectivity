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
  source         = "./Network Security Group"
  resourceSuffix = var.resourceSuffix
  environment    = var.environment
  location       = var.location
}

module "vnet" {
  source                             = "./Virtual Network"
  resourceSuffix                     = var.resourceSuffix
  environment                        = var.environment
  location                           = var.location
  integrationVNETAddressSpace        = var.integrationVNETAddressSpace
  appGatewaySubnetAddressPrefix      = var.appGatewaySubnetAddressPrefix
  gitHubRunnersSubnetAddressPrefix   = var.gitHubRunnersSubnetAddressPrefix
  apimSubnetAddressPrefix            = var.apimSubnetAddressPrefix
  privateEndpointSubnetAddressPrefix = var.privateEndpointSubnetAddressPrefix
  appsSubnetAddressPrefix            = var.appsSubnetAddressPrefix
}

module "private_dns_zone" {
  source         = "./Private DNS Zone"
  resourceSuffix = var.resourceSuffix
  environment    = var.environment
  location       = var.location
}

// Always do App Gateway seperate as it requires things from shared infra i.e. KeyVault and APIM
module "app_gateway" {
  source                        = "./Application Gateway"
  resourceSuffix                = var.resourceSuffix
  environment                   = var.environment
  location                      = var.location
  appGatewayFqdn                = var.appGatewayFqdn
}
