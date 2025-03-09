/**************************************************
Existing Resources
***************************************************/
data "azurerm_subnet" "apgw_subnet" {
  name                 = "snet-${var.resourceSuffix}-${var.environmentGroup}-apgw-${var.locationSuffix}"
  resource_group_name  = local.fullResourceGroupName
  virtual_network_name = "vnet-${var.resourceSuffix}-${var.environmentGroup}-${var.locationSuffix}"
}

data "azurerm_api_management" "apim_internal" {
  name                = "apim-${var.resourceSuffix}-${var.environment}-${var.locationSuffix}"
  resource_group_name = "${var.sharedResourceGroupName}-${var.resourceSuffix}-${var.environment}-${var.locationSuffix}"
}

data "azurerm_user_assigned_identity" "keyvault_secret_reader" {
  name                = "uami-kv-reader-${var.resourceSuffix}-${var.environment}-${var.locationSuffix}"
  resource_group_name = "${var.sharedResourceGroupName}-${var.resourceSuffix}-${var.environment}-${var.locationSuffix}"
}

data "azurerm_key_vault" "keyvault" {
  name                = "kv-${var.resourceSuffix}-${var.environment}-${var.locationSuffix}-${var.kvInstanceIdentifier}"
  resource_group_name = "${var.sharedResourceGroupName}-${var.resourceSuffix}-${var.environment}-${var.locationSuffix}"
}

data "azurerm_key_vault_certificate" "custom_domain_cert" {
  name         = "mitchtest-custom-domain"
  key_vault_id = data.azurerm_key_vault.keyvault.id
}

locals {
  // Only used for nonprod to trust our fake self-signed cert CA
  rootCertificate = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tDQpNSUlCbWpDQ0FVQ2dBd0lCQWdJVWQ4QldVQmdo\nS0V2cDk3Rk9JVitjMXNTTG96Z3dDZ1lJS29aSXpqMEVBd0l3DQpHVEVYTUJVR0ExVUVBd3dPVTJG\ndGNHeGxJRkp2YjNRZ1EwRXdIaGNOTWpVd01qQXpNakF6T0RReldoY05Nall3DQpNakF6TWpBek9E\nUXpXakFaTVJjd0ZRWURWUVFEREE1VFlXMXdiR1VnVW05dmRDQkRRVEJaTUJNR0J5cUdTTTQ5DQpB\nZ0VHQ0NxR1NNNDlBd0VIQTBJQUJIWlJrcjdhT244cHdUblM3RUhla3Y4U21GZ2ZpSC9GRkNtK3h0\nMDZualREDQpIVUt1QURNVCtrVkdmd044OUFIekNIMmhaRnV4bU1aOU42NTAvQUxTNEdXalpqQmtN\nQjhHQTFVZEl3UVlNQmFBDQpGSm5ENFNmWnEyZFJxWVY5dWZDR1dZMm51Zmt6TUJJR0ExVWRFd0VC\nL3dRSU1BWUJBZjhDQVFJd0RnWURWUjBQDQpBUUgvQkFRREFnRUdNQjBHQTFVZERnUVdCQlNadytF\nbjJhdG5VYW1GZmJud2hsbU5wN241TXpBS0JnZ3Foa2pPDQpQUVFEQWdOSUFEQkZBaUJtVGE5MGJ3\ndEVmMm9xUDE3WEZuWjIwVytQRFZvMXJDOEJDYWpGSW16OExnSWhBS3NoDQpITzQxL1NUOTNVZEtP\neC9aanpOdkdITzIzUUovNjB6RitORTlyaHlIDQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tDQo="
}

/**************************************************
New Resources
***************************************************/
// Public IP
resource "azurerm_public_ip" "public_ip" {
  name                = "pip-${var.resourceSuffix}-${var.environment}-appgw-${var.locationSuffix}"
  resource_group_name = local.fullResourceGroupName
  location            = var.location
  sku                 = "Standard"
  sku_tier            = "Regional"
  allocation_method   = "Static"
  ip_version          = "IPv4"
  zones               = ["1", "2", "3"]

  lifecycle {
    prevent_destroy = false
  }
}

// App Gateway
resource "azurerm_application_gateway" "app_gateway" {
  name                = "agw-${var.resourceSuffix}-${var.environment}-${var.locationSuffix}"
  resource_group_name = local.fullResourceGroupName
  location            = var.location

  zones = ["1", "2", "3"]

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.keyvault_secret_reader.id]
  }

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  enable_http2 = true

  autoscale_configuration {
    min_capacity = 2
    max_capacity = 3
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20170401S"
  }

  waf_configuration {
    enabled                  = true
    firewall_mode            = "Prevention"
    rule_set_type            = "OWASP"
    rule_set_version         = "3.0"
    request_body_check       = true
    max_request_body_size_kb = 128
    file_upload_limit_mb     = 100
    disabled_rule_group {
      rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"
      rules = [
        "920300",
        "920330"
      ]
    }

    disabled_rule_group {
      rule_group_name = "REQUEST-931-APPLICATION-ATTACK-RFI"
      rules = [
        "931130"
      ]
    }

    disabled_rule_group {
      rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
      rules = [
        "942100",
        "942110",
        "942180",
        "942200",
        "942260",
        "942340",
        "942370",
        "942430",
        "942440"
      ]
    }

  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = data.azurerm_subnet.apgw_subnet.id
  }

  frontend_port {
    name = "port_443"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "appGwPublicFrontendIp"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }

  frontend_ip_configuration {
    name                          = "appGwPrivateFrontendIp"
    subnet_id                     = data.azurerm_subnet.apgw_subnet.id
    private_ip_address            = var.privateIpAddress
    private_ip_address_allocation = "Static"
  }

  // Only apply fake trusted root in dev/test where we use a self-signed certificate
  dynamic "trusted_root_certificate" {
    for_each = contains(["dev", "test"], var.environment) ? [local.rootCertificate] : []
    content {
      name = "rootcert-mitchtest-appgw"
      data = trusted_root_certificate.value
    }
  }

  ssl_certificate {
    name                = "mitchtestcert"
    key_vault_secret_id = data.azurerm_key_vault_certificate.custom_domain_cert.versionless_secret_id
  }

  // APIM API Gateway Backend setup and routing
  backend_address_pool {
    name         = "apimgatewaybackend"
    ip_addresses = data.azurerm_api_management.apim_internal.private_ip_addresses
  }

  probe {
    name                = "apimgatewayprobe"
    protocol            = "Https"
    host                = local.fullCustomDomain
    path                = "/status-0123456789abcdef"
    interval            = 30
    timeout             = 120
    unhealthy_threshold = 8
  }

  backend_http_settings {
    name                           = "apimPoolGatewaySetting"
    cookie_based_affinity          = "Disabled"
    port                           = 443
    protocol                       = "Https"
    request_timeout                = 180
    probe_name                     = "apimgatewayprobe"
    // Only apply the fake root cert to trusted root if in dev/test
    trusted_root_certificate_names = contains(["dev", "test"], var.environment) ? ["rootcert-mitchtest-appgw"] : []
    host_name                      = local.fullCustomDomain
  }

  http_listener {
    name                           = "apimgatewayprivatelistener"
    frontend_ip_configuration_name = "appGwPrivateFrontendIp"
    frontend_port_name             = "port_443"
    protocol                       = "Https"
    host_name                      = local.fullCustomDomain
    require_sni                    = true
    ssl_certificate_name           = "mitchtestcert"
  }

  request_routing_rule {
    name                       = "apimgatewayrule"
    rule_type                  = "Basic"
    http_listener_name         = "apimgatewayprivatelistener"
    backend_address_pool_name  = "apimgatewaybackend"
    backend_http_settings_name = "apimPoolGatewaySetting"
    priority                   = 10
  }

  // Dev Portal Backend setup and routing
  backend_address_pool {
    name         = "apimportalbackend"
    ip_addresses = data.azurerm_api_management.apim_internal.private_ip_addresses
  }

  probe {
    name                = "apimportalprobe"
    protocol            = "Https"
    host                = "portal.${local.fullCustomDomain}"
    path                = "/signin"
    interval            = 60
    timeout             = 300
    unhealthy_threshold = 8
  }

  backend_http_settings {
    name                           = "apimPoolPortalSetting"
    cookie_based_affinity          = "Disabled"
    port                           = 443
    protocol                       = "Https"
    request_timeout                = 180
    probe_name                     = "apimportalprobe"
    // Only apply the fake root cert to trusted root if in dev/test
    trusted_root_certificate_names = contains(["dev", "test"], var.environment) ? ["rootcert-mitchtest-appgw"] : []
    host_name                      = "portal.${local.fullCustomDomain}"
  }

  http_listener {
    name                           = "apimportalpriatelistener"
    frontend_ip_configuration_name = "appGwPrivateFrontendIp"
    frontend_port_name             = "port_443"
    protocol                       = "Https"
    host_name                      = "portal.${local.fullCustomDomain}"
    require_sni                    = true
    ssl_certificate_name           = "mitchtestcert"
  }

  request_routing_rule {
    name                       = "apimportalrule"
    rule_type                  = "Basic"
    http_listener_name         = "apimportalpriatelistener"
    backend_address_pool_name  = "apimportalbackend"
    backend_http_settings_name = "apimPoolPortalSetting"
    priority                   = 20
  }

  // APIM Management Backend setup and routing
  backend_address_pool {
    name         = "apimmanagementbackend"
    ip_addresses = data.azurerm_api_management.apim_internal.private_ip_addresses
  }

  probe {
    name                = "apimmanagementprobe"
    protocol            = "Https"
    host                = "management.${local.fullCustomDomain}"
    path                = "/ServiceStatus"
    interval            = 60
    timeout             = 300
    unhealthy_threshold = 8
  }

  backend_http_settings {
    name                           = "apimPoolManagementSetting"
    cookie_based_affinity          = "Disabled"
    port                           = 443
    protocol                       = "Https"
    request_timeout                = 180
    probe_name                     = "apimmanagementprobe"
    // Only apply the fake root cert to trusted root if in dev/test
    trusted_root_certificate_names = contains(["dev", "test"], var.environment) ? ["rootcert-mitchtest-appgw"] : []
    host_name                      = "management.${local.fullCustomDomain}"
  }

  http_listener {
    name                           = "apimmanagementprivatelistener"
    frontend_ip_configuration_name = "appGwPrivateFrontendIp"
    frontend_port_name             = "port_443"
    protocol                       = "Https"
    host_name                      = "management.${local.fullCustomDomain}"
    require_sni                    = true
    ssl_certificate_name           = "mitchtestcert"
  }

  request_routing_rule {
    name                       = "apimmanagementrule"
    rule_type                  = "Basic"
    http_listener_name         = "apimmanagementprivatelistener"
    backend_address_pool_name  = "apimmanagementbackend"
    backend_http_settings_name = "apimPoolManagementSetting"
    priority                   = 30
  }

  tags = local.tags

  lifecycle {
    prevent_destroy = false
  }
}