param location string = resourceGroup().location

param publicIPAddresses_pi_inventory_gateway_name string = 'pi-inventory-gateway'

resource publicIPAddresses_pi_inventory_gateway_name_resource 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: publicIPAddresses_pi_inventory_gateway_name
  location: location
  tags: {
    'k8s-azure-dns-label-service': 'ingress-controller/ingress-nginx-controller'
    scope: 'bootstrap'
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    ipAddress: '20.19.173.35'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    dnsSettings: {
      domainNameLabel: 'inventory'
      fqdn: 'inventory.francecentral.cloudapp.azure.com'
    }
    ipTags: []
  }
}

// Virtual network for hub
resource vnetHub 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet-hub'
  location: location
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
        }
      }
      {
        name: 'gateway-subnet'
        properties: {
          addressPrefix: '10.200.0.64/27'
        }
      }
      {
        name: 'bastion-subnet'
        properties: {
          addressPrefix: '10.200.0.128/26'
        }
      }
    ]
  }


  resource azureFirewallSubnet 'subnets' existing = {
    name: 'AzureFirewallSubnet'
  }

}

