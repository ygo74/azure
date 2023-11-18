param parLocation string


module logging 'logging.bicep' = {
  name: 'logging'
  params: {
    parLocation: parLocation
    parLogAnalyticsWorkspaceSkuName: 'Free'
  }
}

// Virtual network for hub
@description('Create the Virtual network for the region Hub')
resource resVnetHub 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet-hub'
  location: parLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.200.0.0/24'
      ]
    }
    subnets: [
      {
        // Azure Firewall can only be created in subnet with name 'AzureFirewallSubnet
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.200.0.0/26'
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'gateway-subnet'
        properties: {
          addressPrefix: '10.200.0.64/27'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'bastion-subnet'
        properties: {
          addressPrefix: '10.200.0.128/26'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }


  resource azureFirewallSubnet 'subnets' existing = {
    name: 'AzureFirewallSubnet'
  }

}

@description('Enable diagnostic for virtaul network')
resource resVnetHub_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'to-hub-la'
  scope: resVnetHub
  properties: {
    workspaceId: logging.outputs.outLogAnalyticsWorkspaceId
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// Outputs
output outVnetHubId string = resVnetHub.id
output outVnetHubName string = resVnetHub.name


