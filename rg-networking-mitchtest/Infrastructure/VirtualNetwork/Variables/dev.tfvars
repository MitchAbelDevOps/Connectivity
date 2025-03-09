# Covers dev and test (nonprod)
environment="dev"

integrationVNETAddressSpace = [
  "10.241.40.0/23"
]

appsSubnetAddressPrefix = [
  "10.241.40.0/24"
]

privateEndpointSubnetAddressPrefix = [
  "10.241.41.0/26"
]

appGatewaySubnetAddressPrefix = [
  "10.241.41.64/27"
]

gitHubRunnersSubnetAddressPrefix = [
  "10.241.41.96/27"
]

apimSubnetAddressPrefix = [
  "10.241.41.128/28"
]

jumpboxSubnetAddressPrefix = [
  "10.241.41.144/29"
]