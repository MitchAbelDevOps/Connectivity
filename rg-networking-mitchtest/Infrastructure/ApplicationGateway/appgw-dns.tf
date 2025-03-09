/**************************************************
Existing Resources
***************************************************/
data "azurerm_private_dns_zone" "apim_custom_dns_zone" {
  name                = local.fullCustomDomain
  resource_group_name = local.fullResourceGroupName
}

/**************************************************
New Resources
***************************************************/
// Explicit A record entries for APIM endpoints
// NOTE: These are added to the DNS zones in the networking resource group.
resource "azurerm_private_dns_a_record" "gateway_record" {
  name                = "@"
  zone_name           = data.azurerm_private_dns_zone.apim_custom_dns_zone.name
  resource_group_name = local.fullResourceGroupName
  ttl                 = 3600
  records             = [
    var.privateIpAddress
  ]

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_private_dns_a_record" "dev_portal_record" {
  name                = "portal"
  zone_name           = data.azurerm_private_dns_zone.apim_custom_dns_zone.name
  resource_group_name = local.fullResourceGroupName
  ttl                 = 3600
  records             = [
    var.privateIpAddress
  ]

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_private_dns_a_record" "mgmt_portal_record" {
  name                = "management"
  zone_name           = data.azurerm_private_dns_zone.apim_custom_dns_zone.name
  resource_group_name = local.fullResourceGroupName
  ttl                 = 3600
  records             = [
    var.privateIpAddress
  ]

  lifecycle {
    prevent_destroy = false
  }
}