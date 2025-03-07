/**************************************************
Existing Resources
***************************************************/
data "azurerm_virtual_network" "vnet_integration" {
  name                = "vnet-${var.resourceSuffix}-${var.environment}-${var.locationSuffix}-01"
  resource_group_name = local.fullResourceGroupName
}

/**************************************************
New Resources
***************************************************/
// KeyVault DNS zone and VNET link
module "keyvault_dns_zone" {
  source                      = "github.com/MitchAbelDevOps/DevOps//TerraformModules/PrivateDNSZones"
  name                        = "privatelink.vaultcore.azure.net"
  resource_group_name         = local.fullResourceGroupName
  virtual_networks_to_link_id = data.azurerm_virtual_network.vnet_integration.id
}

// ServiceBus DNS zone and VNET link
module "servicebus_dns_zone" {
  source                      = "github.com/MitchAbelDevOps/DevOps//TerraformModules/PrivateDNSZones"
  name                        = "privatelink.servicebus.windows.net"
  resource_group_name         = local.fullResourceGroupName
  virtual_networks_to_link_id = data.azurerm_virtual_network.vnet_integration.id
}

// Logic/Function app DNS zone and VNET link
module "apps_dns_zone" {
  source                      = "github.com/MitchAbelDevOps/DevOps//TerraformModules/PrivateDNSZones"
  name                        = "privatelink.azurewebsites.net"
  resource_group_name         = local.fullResourceGroupName
  virtual_networks_to_link_id = data.azurerm_virtual_network.vnet_integration.id
}

// Storage services DNS zones and VNET links
module "storage_files_dns_zone" {
  source                      = "github.com/MitchAbelDevOps/DevOps//TerraformModules/PrivateDNSZones"
  name                        = "privatelink.file.core.windows.net"
  resource_group_name         = local.fullResourceGroupName
  virtual_networks_to_link_id = data.azurerm_virtual_network.vnet_integration.id
}

module "storage_blob_dns_zone" {
  source                      = "github.com/MitchAbelDevOps/DevOps//TerraformModules/PrivateDNSZones"
  name                        = "privatelink.blob.core.windows.net"
  resource_group_name         = local.fullResourceGroupName
  virtual_networks_to_link_id = data.azurerm_virtual_network.vnet_integration.id
}

module "storage_table_dns_zone" {
  source                      = "github.com/MitchAbelDevOps/DevOps//TerraformModules/PrivateDNSZones"
  name                        = "privatelink.table.core.windows.net"
  resource_group_name         = local.fullResourceGroupName
  virtual_networks_to_link_id = data.azurerm_virtual_network.vnet_integration.id
}

module "storage_queue_dns_zone" {
  source                      = "github.com/MitchAbelDevOps/DevOps//TerraformModules/PrivateDNSZones"
  name                        = "privatelink.queue.core.windows.net"
  resource_group_name         = local.fullResourceGroupName
  virtual_networks_to_link_id = data.azurerm_virtual_network.vnet_integration.id
}