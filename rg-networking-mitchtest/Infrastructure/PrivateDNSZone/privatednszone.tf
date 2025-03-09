/**************************************************
Existing Resources
***************************************************/
data "azurerm_virtual_network" "vnet_integration" {
  name                = "vnet-${var.resourceSuffix}-${var.environmentGroup}-${var.locationSuffix}"
  resource_group_name = local.fullResourceGroupName
}

/**************************************************
New Resources
***************************************************/
// KeyVault DNS zone and VNET link
module "keyvault_dns_zone" {
  source                      = "git::https://github.com/MitchAbelDevOps/azure-devops-resources//TerraformModules/PrivateDNSZones"
  name                        = "privatelink.vaultcore.azure.net"
  resource_group_name         = local.fullResourceGroupName
  virtual_networks_to_link_id = data.azurerm_virtual_network.vnet_integration.id
}

// ServiceBus DNS zone and VNET link
module "servicebus_dns_zone" {
  source                      = "git::https://github.com/MitchAbelDevOps/azure-devops-resources//TerraformModules/PrivateDNSZones"
  name                        = "privatelink.servicebus.windows.net"
  resource_group_name         = local.fullResourceGroupName
  virtual_networks_to_link_id = data.azurerm_virtual_network.vnet_integration.id
}

// Logic/Function app DNS zone and VNET link
module "apps_dns_zone" {
  source                      = "git::https://github.com/MitchAbelDevOps/azure-devops-resources//TerraformModules/PrivateDNSZones"
  name                        = "privatelink.azurewebsites.net"
  resource_group_name         = local.fullResourceGroupName
  virtual_networks_to_link_id = data.azurerm_virtual_network.vnet_integration.id
}

// Storage services DNS zones and VNET links
module "storage_files_dns_zone" {
  source                      = "git::https://github.com/MitchAbelDevOps/azure-devops-resources//TerraformModules/PrivateDNSZones"
  name                        = "privatelink.file.core.windows.net"
  resource_group_name         = local.fullResourceGroupName
  virtual_networks_to_link_id = data.azurerm_virtual_network.vnet_integration.id
}
module "storage_blob_dns_zone" {
  source                      = "git::https://github.com/MitchAbelDevOps/azure-devops-resources//TerraformModules/PrivateDNSZones"
  name                        = "privatelink.blob.core.windows.net"
  resource_group_name         = local.fullResourceGroupName
  virtual_networks_to_link_id = data.azurerm_virtual_network.vnet_integration.id
}
module "storage_table_dns_zone" {
  source                      = "git::https://github.com/MitchAbelDevOps/azure-devops-resources//TerraformModules/PrivateDNSZones"
  name                        = "privatelink.table.core.windows.net"
  resource_group_name         = local.fullResourceGroupName
  virtual_networks_to_link_id = data.azurerm_virtual_network.vnet_integration.id
}
module "storage_queue_dns_zone" {
  source                      = "git::https://github.com/MitchAbelDevOps/azure-devops-resources//TerraformModules/PrivateDNSZones"
  name                        = "privatelink.queue.core.windows.net"
  resource_group_name         = local.fullResourceGroupName
  virtual_networks_to_link_id = data.azurerm_virtual_network.vnet_integration.id
}

// APIM DNS zones and VNET links
// Default APIM gateway, allows direct APIM access for testing
# module "apim_gateway_default_dns_zone" {
#   source                      = "git::https://github.com/MitchAbelDevOps/azure-devops-resources//TerraformModules/PrivateDNSZones"
#   name                        = "azure-api.net"
#   resource_group_name         = local.fullResourceGroupName
#   virtual_networks_to_link_id = data.azurerm_virtual_network.vnet_integration.id
# }

// Custom APIM domain for *.{env}-api.internal.mitchtest.nz
module "custom_dns_zone" {
  for_each                    = toset(local.fullCustomDomains)
  source                      = "git::https://github.com/MitchAbelDevOps/azure-devops-resources//TerraformModules/PrivateDNSZones"
  name                        = each.value
  resource_group_name         = local.fullResourceGroupName
  virtual_networks_to_link_id = data.azurerm_virtual_network.vnet_integration.id
}