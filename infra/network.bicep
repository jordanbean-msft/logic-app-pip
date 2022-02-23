param longName string

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: 'pip-${longName}'
  location: resourceGroup().location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    idleTimeoutInMinutes: 4
  }
}

resource natGateway 'Microsoft.Network/natGateways@2021-05-01' = {
  name: 'nat-${longName}'
  location: resourceGroup().location
  sku: {
      name: 'Standard'
  }
  properties: {
    idleTimeoutInMinutes: 4
    publicIpAddresses: [
      {
        id: publicIpAddress.id
      }
    ]
  }
}

var subnetName = 'default'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: 'vnet-${longName}'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '172.18.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '172.18.0.0/24'
          natGateway: {
            id: natGateway.id
          }
          delegations: [
            {
              name: 'delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverfarms'
              }
            }
          ]
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

output virtualNetworkName string = virtualNetwork.name
output virtualNetworkSubnetName string = subnetName
