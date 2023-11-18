// ****************************************************************************
// Networks peering
// ****************************************************************************

// parameters
param parVnetHubName string

param parVnetSpokeName string
param parVnetSpokeId string


resource vnetHub 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
  name: parVnetHubName
}

resource resVnetPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
  parent: vnetHub
  name: '${parVnetHubName}-${parVnetSpokeName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: parVnetSpokeId
    }
  }
}


