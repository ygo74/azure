
// parameters
param location string

// Virtual network for hub
resource resVnetSpoke 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet-spoke'
  location: location
  tags: {
    scope: 'bootstrap'
    virtual_network_kind: 'spoke'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.240.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'net-cluster-nodes'
        properties: {
          addressPrefix: '10.240.0.0/22'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      // Managed by AKS Cluster and specified during the AKS cluster creation
      // {
      //   name: 'net-cluster-services'
      //   properties: {
      //     addressPrefix: '10.240.4.0/28'
      //   }
      // }
      {
        name: 'net-application-gateway'
        properties: {
          addressPrefix: '10.240.5.0/24'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'net-private-links'
        properties: {
          addressPrefix: '10.240.4.32/28'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }

}

// Outputs
output outVnetSpokeId string = resVnetSpoke.id
output outVnetSpokeName string = resVnetSpoke.name
