/**************************************************
Existing Resources
***************************************************/

/**************************************************
New Resources
***************************************************/
resource "azurerm_network_security_group" "appgateway_nsg" {
  name                = "nsg-apgw-${var.resourceSuffix}-${var.environment}-${var.locationSuffix}"
  location            = var.location
  resource_group_name = local.fullResourceGroupName

  security_rule {
    name                       = "AllowHealthProbesInbound"
    priority                   = 100
    protocol                   = "*"
    destination_port_range     = "65200-65535"
    access                     = "Allow"
    direction                  = "Inbound"
    source_port_range          = "*"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowTLSInbound"
    priority                   = 110
    protocol                   = "Tcp"
    destination_port_range     = "443"
    access                     = "Allow"
    direction                  = "Inbound"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPInbound"
    priority                   = 111
    protocol                   = "Tcp"
    destination_port_range     = "80"
    access                     = "Allow"
    direction                  = "Inbound"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAzureLoadBalancerInbound"
    priority                   = 121
    protocol                   = "Tcp"
    destination_port_range     = "*"
    access                     = "Allow"
    direction                  = "Inbound"
    source_port_range          = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }
  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_network_security_group" "apim_nsg" {
  name                = "nsg-apim-${var.resourceSuffix}-${var.environment}-${var.locationSuffix}"
  location            = var.location
  resource_group_name = local.fullResourceGroupName

  security_rule {
    name                       = "AllowApimVnetInbound"
    priority                   = 2000
    protocol                   = "Tcp"
    destination_port_range     = "3443"
    access                     = "Allow"
    direction                  = "Inbound"
    source_port_range          = "*"
    source_address_prefix      = "ApiManagement"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "apim-azure-infra-lb"
    priority                   = 2010
    protocol                   = "Tcp"
    destination_port_range     = "6390"
    access                     = "Allow"
    direction                  = "Inbound"
    source_port_range          = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "apim-azure-storage"
    priority                   = 2000
    protocol                   = "Tcp"
    destination_port_range     = "443"
    access                     = "Allow"
    direction                  = "Outbound"
    source_port_range          = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "Storage"
  }

  security_rule {
    name                       = "apim-azure-sql"
    priority                   = 2010
    protocol                   = "Tcp"
    destination_port_range     = "1443"
    access                     = "Allow"
    direction                  = "Outbound"
    source_port_range          = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "SQL"
  }

  security_rule {
    name                       = "apim-azure-kv"
    priority                   = 2020
    protocol                   = "Tcp"
    destination_port_range     = "443"
    access                     = "Allow"
    direction                  = "Outbound"
    source_port_range          = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "AzureKeyVault"
  }

  security_rule {
    name                       = "apim-azure-monitor"
    priority                   = 2030
    protocol                   = "Tcp"
    destination_port_range     = "443"
    access                     = "Allow"
    direction                  = "Outbound"
    source_port_range          = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "AzureMonitor"
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_network_security_group" "runners_nsg" {
  name                = "nsg-runners-${var.resourceSuffix}-${var.environment}-${var.locationSuffix}" 
  location            = var.location
  resource_group_name = local.fullResourceGroupName

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_network_security_group" "private_endpoint_nsg" {
  name                = "nsg-prep-${var.resourceSuffix}-${var.environment}-${var.locationSuffix}"
  location            = var.location
  resource_group_name = local.fullResourceGroupName

  lifecycle {
    prevent_destroy = false
  }
}