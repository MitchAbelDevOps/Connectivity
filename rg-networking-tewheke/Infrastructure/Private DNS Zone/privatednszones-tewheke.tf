/**************************************************
Existing Resources
***************************************************/
data "azurerm_virtual_network" "vnet_integration" {
  name                = "vnet-integration-${var.resourceSuffix}"
  resource_group_name = var.resourceGroupName
}

/**************************************************
New Resources
***************************************************/
// KeyVault DNS zone and VNET link
module "keyvault_dns_zone" {
  source                      = "github.com/MitchAbelDevOps/DevOps/TerraformModules//PrivateDNSZones"
  name                        = "privatelink.vaultcore.azure.net"
  resource_group_name         = var.resourceGroupName
  virtual_networks_to_link_id = data.azurerm_virtual_network.vnet_integration.id
}

// ServiceBus DNS zone and VNET link
module "servicebus_dns_zone" {
  source                      = "github.com/MitchAbelDevOps/DevOps/TerraformModules//PrivateDNSZones"
  name                        = "privatelink.servicebus.windows.net"
  resource_group_name         = var.resourceGroupName
  virtual_networks_to_link_id = data.azurerm_virtual_network.vnet_integration.id
}

// APIM DNS zones and VNET links
module "api_gateway_dns_zone" {
  source                      = "github.com/MitchAbelDevOps/DevOps/TerraformModules//PrivateDNSZones"
  name                        = "azure-api.net"
  resource_group_name         = var.resourceGroupName
  virtual_networks_to_link_id = data.azurerm_virtual_network.vnet_integration.id
}

module "old_developer_portal_dns_zone" {
  source                      = "github.com/MitchAbelDevOps/DevOps/TerraformModules//PrivateDNSZones"
  name                        = "portal.azure-api.net"
  resource_group_name         = var.resourceGroupName
  virtual_networks_to_link_id = data.azurerm_virtual_network.vnet_integration.id
}

module "new_developer_portal_dns_zone" {
  source                      = "github.com/MitchAbelDevOps/DevOps/TerraformModules//PrivateDNSZones"
  name                        = "developer.azure-api.net"
  resource_group_name         = var.resourceGroupName
  virtual_networks_to_link_id = data.azurerm_virtual_network.vnet_integration.id
}

module "mgmt_portal_dns_zone" {
  source                      = "github.com/MitchAbelDevOps/DevOps/TerraformModules//PrivateDNSZones"
  name                        = "management.azure-api.net"
  resource_group_name         = var.resourceGroupName
  virtual_networks_to_link_id = data.azurerm_virtual_network.vnet_integration.id
}

module "apim_git_dns_zone" {
  source                      = "github.com/MitchAbelDevOps/DevOps/TerraformModules//PrivateDNSZones"
  name                        = "scm.azure-api.net"
  resource_group_name         = var.resourceGroupName
  virtual_networks_to_link_id = data.azurerm_virtual_network.vnet_integration.id
}