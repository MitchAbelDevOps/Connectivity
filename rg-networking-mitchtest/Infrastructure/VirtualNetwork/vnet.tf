/**************************************************
Existing Resources
***************************************************/
data "azurerm_network_security_group" "appgateway_nsg" {
  name                = "nsg-${var.resourceSuffix}-${var.environmentGroup}-apgw-${var.locationSuffix}"
  resource_group_name = local.fullResourceGroupName
}

data "azurerm_network_security_group" "runners_nsg" {
  name                = "nsg-${var.resourceSuffix}-${var.environmentGroup}-runners-${var.locationSuffix}"
  resource_group_name = local.fullResourceGroupName
}

data "azurerm_network_security_group" "apim_nsg" {
  name                = "nsg-${var.resourceSuffix}-${var.environmentGroup}-apim-${var.locationSuffix}"
  resource_group_name = local.fullResourceGroupName
}

data "azurerm_network_security_group" "private_endpoint_nsg" {
  name                = "nsg-${var.resourceSuffix}-${var.environmentGroup}-pep-${var.locationSuffix}"
  resource_group_name = local.fullResourceGroupName
}

data "azurerm_network_security_group" "apps_nsg" {
  name                = "nsg-${var.resourceSuffix}-${var.environmentGroup}-apps-${var.locationSuffix}"
  resource_group_name = local.fullResourceGroupName
}

data "azurerm_network_security_group" "jumpbox_nsg" {
  name                = "nsg-${var.resourceSuffix}-${var.environmentGroup}-jumpbox-${var.locationSuffix}"
  resource_group_name = local.fullResourceGroupName
}

/**************************************************
New Resources
***************************************************/
// VNET
resource "azurerm_virtual_network" "vnet_integration" {
  name                = "vnet-${var.resourceSuffix}-${var.environmentGroup}-${var.locationSuffix}"
  location            = var.location
  resource_group_name = local.fullResourceGroupName
  address_space       = var.integrationVNETAddressSpace

  tags = local.tags

  lifecycle {
    prevent_destroy = false
  }
}

// Subnets and NSG associations
resource "azurerm_subnet" "appgateway_subnet" {
  name                 = "snet-${var.resourceSuffix}-${var.environmentGroup}-apgw-${var.locationSuffix}"
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
  name                 = "snet-${var.resourceSuffix}-${var.environmentGroup}-runners-${var.locationSuffix}"
  resource_group_name  = local.fullResourceGroupName
  virtual_network_name = azurerm_virtual_network.vnet_integration.name
  address_prefixes     = var.gitHubRunnersSubnetAddressPrefix

  service_endpoints = ["Microsoft.Storage", "Microsoft.Web"]

  delegation {
    name = "Microsoft.App/environments"
    service_delegation {
      name    = "Microsoft.App/environments"
    }
  }

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
  name                 = "snet-${var.resourceSuffix}-${var.environmentGroup}-apim-${var.locationSuffix}"
  resource_group_name  = local.fullResourceGroupName
  virtual_network_name = azurerm_virtual_network.vnet_integration.name
  address_prefixes     = var.apimSubnetAddressPrefix

  service_endpoints = ["Microsoft.Web", "Microsoft.KeyVault"]

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
  name                 = "snet-${var.resourceSuffix}-${var.environmentGroup}-pep-${var.locationSuffix}"
  resource_group_name  = local.fullResourceGroupName
  virtual_network_name = azurerm_virtual_network.vnet_integration.name
  address_prefixes     = var.privateEndpointSubnetAddressPrefix

  service_endpoints = ["Microsoft.Storage"]

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

resource "azurerm_subnet" "apps_subnet" {
  name                 = "snet-${var.resourceSuffix}-${var.environmentGroup}-apps-${var.locationSuffix}"
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

resource "azurerm_subnet_network_security_group_association" "apps_subnet" {
  subnet_id                 = azurerm_subnet.apps_subnet.id
  network_security_group_id = data.azurerm_network_security_group.apps_nsg.id

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_subnet" "jumpbox_subnet" {
  name                 = "snet-${var.resourceSuffix}-${var.environmentGroup}-jumpbox-${var.locationSuffix}"
  resource_group_name  = local.fullResourceGroupName
  virtual_network_name = azurerm_virtual_network.vnet_integration.name
  address_prefixes     = var.jumpboxSubnetAddressPrefix

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_subnet_network_security_group_association" "jumpbox_subnet" {
  subnet_id                 = azurerm_subnet.jumpbox_subnet.id
  network_security_group_id = data.azurerm_network_security_group.jumpbox_nsg.id

  lifecycle {
    prevent_destroy = false
  }
}