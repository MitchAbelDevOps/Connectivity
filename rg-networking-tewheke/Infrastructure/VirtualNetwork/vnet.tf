/**************************************************
Existing Resources
***************************************************/
data "azurerm_network_security_group" "appgateway_nsg" {
  name                = "nsg-${var.resourceSuffix}-${var.environment}-apgw-${var.locationSuffix}-01"
  resource_group_name = local.fullResourceGroupName
}

data "azurerm_network_security_group" "runners_nsg" {
  name                = "nsg-${var.resourceSuffix}-${var.environment}-runners-${var.locationSuffix}-01"
  resource_group_name = local.fullResourceGroupName
}

data "azurerm_network_security_group" "apim_nsg" {
  name                = "nsg-${var.resourceSuffix}-${var.environment}-apim-${var.locationSuffix}-01"
  resource_group_name = local.fullResourceGroupName
}

data "azurerm_network_security_group" "private_endpoint_nsg" {
  name                = "nsg-${var.resourceSuffix}-${var.environment}-prep-${var.locationSuffix}-01"
  resource_group_name = local.fullResourceGroupName
}

/**************************************************
New Resources
***************************************************/
// VNET
resource "azurerm_virtual_network" "vnet_integration" {
  name                = "vnet-${var.resourceSuffix}-${var.environment}-${var.locationSuffix}-01"
  location            = var.location
  resource_group_name = local.fullResourceGroupName
  address_space       = var.integrationVNETAddressSpace

  lifecycle {
    prevent_destroy = false
  }
}

// Subnets and NSG associations
resource "azurerm_subnet" "appgateway_subnet" {
  name                 = "snet-${var.resourceSuffix}-${var.environment}-apgw-${var.locationSuffix}-01"
  resource_group_name  = local.fullResourceGroupName
  virtual_network_name = azurerm_virtual_network.vnet_integration.name
  address_prefixes     = var.appGatewaySubnetAddressPrefix

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_subnet_network_security_group_association" "appgateway_subnet" {
  subnet_id                 = azurerm_subnet.appgateway_subnet.id
  network_security_group_id = data.azurerm_network_security_group.appgateway_nsg.id

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_subnet" "runners_subnet" {
  name                 = "snet-${var.resourceSuffix}-${var.environment}-runners-${var.locationSuffix}-01"
  resource_group_name  = local.fullResourceGroupName
  virtual_network_name = azurerm_virtual_network.vnet_integration.name
  address_prefixes     = var.gitHubRunnersSubnetAddressPrefix

  delegation {
    name = "Microsoft.App/environments"
    service_delegation {
      name    = "Microsoft.App/environments"
    }
  }

  service_endpoints = [ Microsoft.Storage ]

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_subnet_network_security_group_association" "runners_subnet" {
  subnet_id                 = azurerm_subnet.runners_subnet.id
  network_security_group_id = data.azurerm_network_security_group.runners_nsg.id

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_subnet" "apim_subnet" {
  name                 = "snet-${var.resourceSuffix}-${var.environment}-apim-${var.locationSuffix}-01"
  resource_group_name  = local.fullResourceGroupName
  virtual_network_name = azurerm_virtual_network.vnet_integration.name
  address_prefixes     = var.apimSubnetAddressPrefix

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_subnet_network_security_group_association" "apim_subnet" {
  subnet_id                 = azurerm_subnet.apim_subnet.id
  network_security_group_id = data.azurerm_network_security_group.apim_nsg.id

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_subnet" "private_endpoint_subnet" {
  name                 = "snet-${var.resourceSuffix}-${var.environment}-prep-${var.locationSuffix}-01"
  resource_group_name  = local.fullResourceGroupName
  virtual_network_name = azurerm_virtual_network.vnet_integration.name
  address_prefixes     = var.privateEndpointSubnetAddressPrefix

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_subnet_network_security_group_association" "private_endpoint_subnet" {
  subnet_id                 = azurerm_subnet.private_endpoint_subnet.id
  network_security_group_id = data.azurerm_network_security_group.private_endpoint_nsg.id

  lifecycle {
    prevent_destroy = false
  }
}

//TODO add an NSG for the apps subnet
resource "azurerm_subnet" "deploy_subnet" {
  name                 = "snet-${var.resourceSuffix}-${var.environment}-apps-${var.locationSuffix}-01"
  resource_group_name  = local.fullResourceGroupName
  virtual_network_name = azurerm_virtual_network.vnet_integration.name
  address_prefixes     = var.appsSubnetAddressPrefix

  service_endpoints = ["Microsoft.Storage"]

  delegation {
    name = "Microsoft.Web/serverFarms"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
    }
  }

  lifecycle {
    prevent_destroy = false
  }
}

//TODO add hub peering