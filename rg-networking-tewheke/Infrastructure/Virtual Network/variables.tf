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

/**************************************************
New Resource Variables
***************************************************/
variable "resourceGroupName" {
  type        = string
  description = "The name of the resource group"
  default     = "rg-networking"
}

variable "integrationVNETAddressSpace" {
  type = list(string)
  description = "List of CIDR IP ranges to provision as the total address space for the integration VNET"
}

variable "appGatewaySubnetAddressPrefix" {
  type = list(string)
  description = "value"
}

variable "gitHubRunnersSubnetAddressPrefix" {
  type = list(string)
  description = "value"
}

variable "apimSubnetAddressPrefix" {
  type = list(string)
  description = "value"
}

variable "privateEndpointSubnetAddressPrefix" {
  type = list(string)
  description = "value"
}

variable "appsSubnetAddressPrefix" {
  type = list(string)
  description = "value"
}