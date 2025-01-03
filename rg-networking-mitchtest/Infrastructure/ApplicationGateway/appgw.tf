/**************************************************
Existing Resources
***************************************************/
data "azurerm_subnet" "apgw_subnet" {
  name                 = "snet-${var.resourceSuffix}-${var.environment}-apgw-${var.locationSuffix}-01"
  resource_group_name  = local.fullResourceGroupName
  virtual_network_name = "vnet-${var.resourceSuffix}-${var.environment}-${var.locationSuffix}-01"
}

data "azurerm_api_management" "apim_internal" {
  name                = "apim-mitchtest-${var.resourceSuffix}-${var.environment}-${var.locationSuffix}-01"
  resource_group_name = "${var.sharedResourceGroupName}-${var.resourceSuffix}-${var.environment}-${var.locationSuffix}"
}

data "azurerm_user_assigned_identity" "keyvault_secret_reader" {
  name                = "uami-kv-reader-${var.resourceSuffix}-${var.environment}-${var.locationSuffix}"
  resource_group_name = "${var.sharedResourceGroupName}-${var.resourceSuffix}-${var.environment}-${var.locationSuffix}"
}

/**************************************************
New Resources
***************************************************/
// Public IP
resource "azurerm_public_ip" "public_ip" {
  name                = "pip-${var.resourceSuffix}-${var.environment}-appgw-${var.locationSuffix}-01"
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

// TODO add app gateway CERT to KV here?

// App Gateway
resource "azurerm_application_gateway" "app_gateway" {
  name                = "agw-${var.resourceSuffix}-${var.environment}-${var.locationSuffix}-01"
  resource_group_name = local.fullResourceGroupName
  location            = var.location

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.keyvault_secret_reader.id]
  }

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  #   ssl_certificate {
  #     name                = var.appGatewayFqdn
  #     key_vault_secret_id = "https://${var.keyVaultName}.vault.azure.net:443/secrets/${local.secretName}"
  #   }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = data.azurerm_subnet.apgw_subnet.id
  }

  frontend_ip_configuration {
    name                          = "appGwPublicFrontendIp"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  frontend_port {
    name = "port_80"
    port = 80
  }

  frontend_port {
    name = "port_443"
    port = 443
  }

  backend_address_pool {
    name  = "apim"
    # fqdns = apim
  }

  backend_http_settings {
    name                                = "default"
    port                                = 80
    protocol                            = "Http"
    cookie_based_affinity               = "Disabled"
    pick_host_name_from_backend_address = false
    affinity_cookie_name                = "ApplicationGatewayAffinity"
    request_timeout                     = 20

  }

  backend_http_settings {
    name                                = "https"
    port                                = 443
    protocol                            = "Https"
    cookie_based_affinity               = "Disabled"
    host_name                           = data.azurerm_api_management.apim_internal.gateway_url
    pick_host_name_from_backend_address = false
    request_timeout                     = 20
    probe_name                          = "APIM"
  }

  http_listener {
    name                           = "default"
    frontend_ip_configuration_name = "appGwPublicFrontendIp"
    frontend_port_name             = "port_80"
    protocol                       = "Http"
    require_sni                    = false
  }

  http_listener {
    name                           = "https"
    frontend_ip_configuration_name = "appGwPublicFrontendIp"
    frontend_port_name             = "port_443"
    protocol                       = "Https"
    require_sni                    = false
    # ssl_certificate_name           = var.appGatewayFqdn
  }

  request_routing_rule {
    name                       = "apim"
    rule_type                  = "Basic"
    http_listener_name         = "https"
    backend_address_pool_name  = "apim"
    backend_http_settings_name = "https"
    priority                   = 100
  }

  probe {
    name                                      = "APIM"
    protocol                                  = "Https"
    host                                      = data.azurerm_api_management.apim_internal.gateway_url
    // TODO may need to parameterise this path?
    path                                      = "/status-0123456789abcdef"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = false
    minimum_servers                           = 0

    match {
      status_code = ["200-399"]
    }
  }

  waf_configuration {
    enabled                  = true
    firewall_mode            = "Detection"
    rule_set_type            = "OWASP"
    rule_set_version         = "3.0"
    request_body_check       = true
    max_request_body_size_kb = 128
    file_upload_limit_mb     = 100
  }

  enable_http2 = true

  autoscale_configuration {
    min_capacity = 2
    max_capacity = 3
  }

  lifecycle {
    prevent_destroy = false
  }
}
