/**************************************************
Global Variables
***************************************************/
variable "location" {
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
/**************************************************
Existing Resource Variables
***************************************************/
variable "sharedResourceGroupName" {
  type        = string
  description = "The name of the shared resources resource group"
  default     = "rg-shared"
}

/**************************************************
New Resource Variables
***************************************************/
variable "resourceGroupName" {
  type        = string
  description = "The name of the resource group"
  default     = "rg-networking"
}

variable "appGatewayFqdn" {
  type        = string
  description = "The Azure location to deploy to"
}
