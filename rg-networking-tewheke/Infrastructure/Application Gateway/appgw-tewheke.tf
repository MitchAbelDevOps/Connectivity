/**************************************************
Existing Resources
***************************************************/
data "azurerm_subnet" "apgw_subnet" {
  name                 = "snet-apgw-${var.resourceSuffix}"
  resource_group_name  = var.resourceGroupName
  virtual_network_name = "vnet-apim-cs-${var.resourceSuffix}"
}

data "azurerm_api_management" "apim_internal" {
  name                = "apim-${var.resourceSuffix}"
  resource_group_name = var.sharedResourceGroupName
}

/**************************************************
New Resources
***************************************************/
// Public IP
resource "azurerm_public_ip" "public_ip" {
  name                = "pip-appgw-${var.resourceSuffix}"
  resource_group_name = var.resourceGroupName
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
  name                = "appgw-${var.resourceSuffix}"
  resource_group_name = var.resourceGroupName
  location            = var.location

  depends_on = []

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.user_assigned_identity.id]
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
    subnet_id = azurerm_subnet.apgw_subnet.id
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
    fqdns = apim
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
    host_name                           = azurerm_api_management.apim_internal.gateway_url
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
    ssl_certificate_name           = var.appGatewayFqdn
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
    host                                      = azurerm_api_management.apim_internal.gateway_url
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
