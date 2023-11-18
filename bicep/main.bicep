

param location string = resourceGroup().location

@description('Set to true to include one Windows and one Linux virtual machine for you to experience peering, gateway transit, and bastion access. Default is false.')
param deployVirtualMachines bool = false


@minLength(3)
@maxLength(24)
param storageName string = 'saygo74bootstrap'

param locationName string = 'francecentral'

/*** VARIABLES ***/

var suffix = uniqueString(subscription().subscriptionId, resourceGroup().id)


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

// ****************************************************************************
// Log Analytics
// ****************************************************************************
@description('This Log Analyics Workspace stores logs from the regional hub network, its spokes, and other related resources. Workspaces are regional resource, as such there would be one workspace per hub (region)')
resource laHub 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: 'la-hub-${location}-${suffix}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
    forceCmkForQuery: false
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    features: {
      disableLocalAuth: false
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: -1
    }
  }
}

resource laHub_diagnosticsSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'to-hub-la'
  scope: laHub
  properties: {
    workspaceId: laHub.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}


// ****************************************************************************
// Firewall configuration
// ****************************************************************************

// Public IP
// Allocate three IP addresses to the firewall
var numFirewallIpAddressesToAssign = 3

resource pipsAzureFirewall 'Microsoft.Network/publicIPAddresses@2022-01-01' = [for i in range(0, numFirewallIpAddressesToAssign): {
  name: 'pip-fw-${location}-${padLeft(i, 2, '0')}'
  location: location
  sku: {
    name: 'Standard'
  }
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    publicIPAddressVersion: 'IPv4'
  }
}]

// Default network rules
// This network hub starts out with only supporting external DNS queries. This is only being done for
// simplicity in this deployment and is not guidance, please ensure all firewall rules are aligned with
// your security standards.

@description('Azure Firewall Policy')
resource fwPolicy 'Microsoft.Network/firewallPolicies@2022-01-01' = {
  name: 'fw-policies-${location}'
  location: location
  properties: {
    sku: {
      tier: 'Standard'
    }
    threatIntelMode: 'Deny'
    insights: {
      isEnabled: true
      retentionDays: 30
      logAnalyticsResources: {
        defaultWorkspaceId: {
          id: laHub.id
        }
      }
    }
    threatIntelWhitelist: {
      fqdns: []
      ipAddresses: []
    }
    intrusionDetection: null // Only valid on Premium tier sku
    dnsSettings: {
      servers: []
      enableProxy: true
    }
  }

  resource defaultNetworkRuleCollectionGroup 'ruleCollectionGroups@2022-01-01' = {
    name: 'DefaultNetworkRuleCollectionGroup'
    properties: {
      priority: 200
      ruleCollections: [
        {
          ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
          name: 'org-wide-allowed'
          priority: 100
          action: {
            type: 'Allow'
          }
          rules: [
            {
              ruleType: 'NetworkRule'
              name: 'DNS'
              description: 'Allow DNS outbound (for simplicity, adjust as needed)'
              ipProtocols: [
                'UDP'
              ]
              sourceAddresses: [
                '*'
              ]
              sourceIpGroups: []
              destinationAddresses: [
                '*'
              ]
              destinationIpGroups: []
              destinationFqdns: []
              destinationPorts: [
                '53'
              ]
            }
          ]
        }
      ]
    }
  }


  // Firewall application rules
  // Network hub starts out with no allowances for appliction rules
  resource defaultApplicationRuleCollectionGroup 'ruleCollectionGroups@2022-01-01' = {
    name: 'DefaultApplicationRuleCollectionGroup'
    dependsOn: [
      defaultNetworkRuleCollectionGroup
    ]
    properties: {
      priority: 300
      ruleCollections: [
        {
          ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
          name: 'org-wide-allowed'
          priority: 100
          action: {
            type: 'Allow'
          }
          rules: deployVirtualMachines ? [
            {
              ruleType: 'ApplicationRule'
              name: 'WindowsVirtualMachineHealth'
              description: 'Supports Windows Updates and Windows Diagnostics'
              fqdnTags: [
                'WindowsDiagnostics'
                'WindowsUpdate'
              ]
              protocols: [
                {
                  protocolType: 'Https'
                  port: 443
                }
              ]
              sourceAddresses: [
                '10.200.0.0/24' // The subnet that contains the Windows VMs
              ]
            }
          ] : []
        }
      ]
    }
  }
}

@description('This is the regional Azure Firewall that all regional spoke networks can egress through.')
resource fwHub 'Microsoft.Network/azureFirewalls@2022-01-01' = {
  name: 'fw-${location}'
  location: location
  zones: [
    '1'
    '2'
    '3'
  ]
  dependsOn: [
    // This helps prevent multiple PUT updates happening to the firewall causing a CONFLICT race condition
    // Ref: https://learn.microsoft.com/azure/firewall-manager/quick-firewall-policy
    fwPolicy::defaultApplicationRuleCollectionGroup
    fwPolicy::defaultNetworkRuleCollectionGroup
  ]
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    firewallPolicy: {
      id: fwPolicy.id
    }
    ipConfigurations: [for i in range(0, numFirewallIpAddressesToAssign): {
      name: pipsAzureFirewall[i].name
      properties: {
        subnet: (0 == i) ? {
          id: vnetHub::azureFirewallSubnet.id
        } : null
        publicIPAddress: {
          id: pipsAzureFirewall[i].id
        }
      }
    }]
  }
}

resource fwHub_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'to-hub-la'
  scope: fwHub
  properties: {
    workspaceId: laHub.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}


