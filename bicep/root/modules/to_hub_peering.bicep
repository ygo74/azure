// ****************************************************************************
// Networks peering
// ****************************************************************************

// parameters
param parVnetHubName string
param parVnetHubId string

param parVnetSpokeName string


resource vnetSpoke 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
  name: parVnetSpokeName
}

resource resVnetPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
  parent: vnetSpoke
  name: '${parVnetSpokeName}-${parVnetHubName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: parVnetHubId
    }
  }
}
