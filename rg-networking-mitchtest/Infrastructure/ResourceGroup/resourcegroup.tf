/**************************************************
Existing Resources
***************************************************/


/**************************************************
New Resources
***************************************************/
// Resource Group
resource "azurerm_resource_group" "resourceGroup" {
  name = local.fullResourceGroupName
  location = var.location
}
