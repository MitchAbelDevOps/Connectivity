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
  description = "Custom domain root to apply to Mitchtest services"
  default     = "internal.mitchtest.nz"
}

locals {
  fullResourceGroupName = "${var.resourceGroupName}-${var.resourceSuffix}-${var.environmentGroup}-${var.locationSuffix}"

  environment_mapping = var.environmentGroup == "npe" ? ["dev", "test"] : var.environmentGroup == "ppe" ? ["stg", "pwe"] : var.environmentGroup == "prd" ? ["prd"] : []
  fullCustomDomain = var.environment == "prd" ? "api.${var.customDomainRoot}" : "${var.environment}-api.${var.customDomainRoot}"
  fullCustomDomains = [for env in local.environment_mapping :
    env == "prd" ? "api.${var.customDomainRoot}" : "${env}-api.${var.customDomainRoot}"
  ]
}