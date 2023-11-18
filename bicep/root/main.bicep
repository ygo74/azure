metadata description = 'Create the subscription root resources group and networks'

targetScope = 'subscription'

@description('Name of the hub resource group to create.')
param rgHubName string = 'rg-francecentral-networking-hub'

@description('Name of the spoke aks resource group to create.')
param rgSpokeAksName string = 'rg-aks-bootstrap-networking-spoke'

@description('Azure Region the resource group will be created in.')
param parLocation string = deployment().location

// ****************************************************************************
// Resources groups
// ****************************************************************************

resource rgHub 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgHubName
  location: parLocation
  tags: {
    scope: 'bootstrap'
  }
}

resource rgSpokeAks 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgSpokeAksName
  location: parLocation
  tags: {
    scope: 'bootstrap'
  }
}


// ****************************************************************************
// Resources Virtual network hub
// ****************************************************************************
module hub 'modules/hub.bicep' = {
  name: 'vnet-hub'
  scope: rgHub
  params: {
    parLocation: parLocation
  }
}

// ****************************************************************************
// Resources Virtual network spokeAks
// ****************************************************************************
module spokeAks 'modules/spokeAks.bicep' = {
  name: 'vnet-spoke'
  scope: rgSpokeAks
  params: {
    location: parLocation
  }
}

// enable peering
module to_spoke_peering 'modules/to_spoke_peering.bicep' = {
  name: 'to_spoke_peering'
  scope: rgHub
  params: {
    parVnetHubName: hub.outputs.outVnetHubName
    parVnetSpokeName: spokeAks.outputs.outVnetSpokeName
    parVnetSpokeId: spokeAks.outputs.outVnetSpokeId
  }
}

module to_hub_peering 'modules/to_hub_peering.bicep' = {
  name: 'to_hub_peering'
  scope: rgSpokeAks
  params: {
    parVnetHubName: hub.outputs.outVnetHubName
    parVnetHubId: hub.outputs.outVnetHubId
    parVnetSpokeName: spokeAks.outputs.outVnetSpokeName
  }
}


// // ****************************************************************************
// // Networks peering
// // ****************************************************************************
// resource vnetHub 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
//   name: 'vnet-hub'
//   scope: rgHub
// }

// resource vnetSpokeAks 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
//   name: 'vnet-spoke'
//   scope: rgSpokeAks
// }

// resource VnetPeering1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
//   parent: vnetHub
//   name: '${vnet1Name}-${vnet2Name}'
//   properties: {
//     allowVirtualNetworkAccess: true
//     allowForwardedTraffic: false
//     allowGatewayTransit: false
//     useRemoteGateways: false
//     remoteVirtualNetwork: {
//       id: vnet2.id
//     }
//   }
// }

