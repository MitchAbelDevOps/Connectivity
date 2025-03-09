/**************************************************
Global Variables
***************************************************/
variable "location" {
  type        = string
  description = "The Azure location in which the deployment is happening"
}

variable "locationSuffix" {
  type        = string
  description = "The Azure location in which the deployment is happening"
}

variable "resourceSuffix" {
  type        = string
  description = "A suffix for naming"
}

variable "environment" {
  type        = string
  description = "Environment"
}

variable "environmentGroup" {
  type = string
}

/**************************************************
Existing Resource Variables
***************************************************/
variable "sharedResourceGroupName" {
  type        = string
  description = "The name of the shared resources resource group"
  default     = "rg-shared"
}

variable "kvInstanceIdentifier" {
  type = string
}

/**************************************************
New Resource Variables
***************************************************/
variable "resourceGroupName" {
  type        = string
  description = "The name of the resource group to deploy to"
  default     = "rg-networking"
}

variable "customDomainRoot" {
  type        = string
  description = "Root of custom domain"
  default     = "internal.mitchtest.nz"
}

variable "privateIpAddress" {
  type        = string
  description = "IP from the appgw subnet to apply for static allocation"
}

locals {
  fullResourceGroupName = "${var.resourceGroupName}-${var.resourceSuffix}-${var.environmentGroup}-${var.locationSuffix}"
  fullCustomDomain      = var.environment == "prd" ? "api.${var.customDomainRoot}" : "${var.environment}-api.${var.customDomainRoot}"
  tags = {
    "application-name"  = "Mitchtest Networking"
    "environment"       = var.environment
    "owner"             = "mitch.abel@adaptiv.nz"
    "primary-support"   = ""
    "rc-code"           = ""
    "secondary-support" = "Adaptiv"
  }
}