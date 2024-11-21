/**************************************************
Existing Resources
***************************************************/
data "azurerm_network_security_group" "appgateway_nsg" {
  name                = "nsg-apgw-${var.resourceSuffix}"
  resource_group_name = var.resourceGroupName
}

data "azurerm_network_security_group" "runners_nsg" {
  name                = "nsg-runners-${var.resourceSuffix}"
  resource_group_name = var.resourceGroupName
}

data "azurerm_network_security_group" "apim_nsg" {
  name                = "nsg-apim-${var.resourceSuffix}"
  resource_group_name = var.resourceGroupName
}

data "azurerm_network_security_group" "private_endpoint_nsg" {
  name                = "nsg-prep-${var.resourceSuffix}"
  resource_group_name = var.resourceGroupName
}

/**************************************************
New Resources
***************************************************/
// VNET
resource "azurerm_virtual_network" "vnet_integration" {
  name                = "vnet-integration-${var.resourceSuffix}"
  location            = var.location
  resource_group_name = var.resourceGroupName
  address_space       = var.integrationVNETAddressSpace

  lifecycle {
    prevent_destroy = false
  }
}

// Subnets and NSG associations
resource "azurerm_subnet" "appgateway_subnet" {
  name                 = "snet-apgw-${var.resourceSuffix}"
  resource_group_name  = var.resourceGroupName
  virtual_network_name = azurerm_virtual_network.vnet_integration.name
  address_prefixes     = var.appGatewaySubnetAddressPrefix

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_subnet_network_security_group_association" "appgateway_subnet" {
  subnet_id                 = azurerm_subnet.appgateway_subnet.id
  network_security_group_id = azurerm_network_security_group.appgateway_nsg.id

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_subnet" "runners_subnet" {
  name                 = "snet-runners-${var.resourceSuffix}"
  resource_group_name  = var.resourceGroupName
  virtual_network_name = azurerm_virtual_network.apim_cs_vnet.name
  address_prefixes     = var.gitHubRunnersSubnetAddressPrefix

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_subnet_network_security_group_association" "runners_subnet" {
  subnet_id                 = azurerm_subnet.runners_subnet.id
  network_security_group_id = azurerm_network_security_group.runners_snnsg_nsg.id

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_subnet" "apim_subnet" {
  name                 = "snet-apim-${var.resourceSuffix}"
  resource_group_name  = var.resourceGroupName
  virtual_network_name = azurerm_virtual_network.apim_cs_vnet.name
  address_prefixes     = var.apimSubnetAddressPrefix

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_subnet_network_security_group_association" "apim_subnet" {
  subnet_id                 = azurerm_subnet.apim_subnet.id
  network_security_group_id = azurerm_network_security_group.apim_snnsg_nsg.id

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_subnet" "private_endpoint_subnet" {
  name                 = "snet-prep-${var.resourceSuffix}"
  resource_group_name  = var.resourceGroupName
  virtual_network_name = azurerm_virtual_network.apim_cs_vnet.name
  address_prefixes     = var.privateEndpointSubnetAddressPrefix

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_subnet_network_security_group_association" "private_endpoint_subnet" {
  subnet_id                 = azurerm_subnet.private_endpoint_subnet.id
  network_security_group_id = azurerm_network_security_group.private_endpoint_snnsg_nsg.id

  lifecycle {
    prevent_destroy = false
  }
}

//TODO add an NSG for the apps subnet
resource "azurerm_subnet" "deploy_subnet" {
  name                 = "snet-apps-${var.resourceSuffix}"
  resource_group_name  = var.resourceGroupName
  virtual_network_name = azurerm_virtual_network.apim_cs_vnet.name
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