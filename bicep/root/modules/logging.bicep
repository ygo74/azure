
// ******************************************************************************
// Deploy log Analytics workspqce for the regionql hub
// To check :
//  - solutions to add to the log analytics : https://github.com/Azure/ALZ-Bicep/blob/main/infra-as-code/bicep/modules/logging/logging.bicep
// ******************************************************************************

// Parameters
param parLocation string

@allowed([
  'CapacityReservation'
  'Free'
  'LACluster'
  'PerGB2018'
  'PerNode'
  'Premium'
  'Standalone'
  'Standard'
])
@sys.description('Log Analytics Workspace sku name.')
param parLogAnalyticsWorkspaceSkuName string = 'Free'

@allowed([
  100
  200
  300
  400
  500
  1000
  2000
  5000
])
@sys.description('Log Analytics Workspace Capacity Reservation Level. Only used if parLogAnalyticsWorkspaceSkuName is set to CapacityReservation.')
param parLogAnalyticsWorkspaceCapacityReservationLevel int = 100

@minValue(30)
@maxValue(730)
@sys.description('Number of days of log retention for Log Analytics Workspace.')
param parLogAnalyticsWorkspaceLogRetentionInDays int = 365



@description('This Log Analyics Workspace stores logs from the regional hub network, its spokes, and other related resources. Workspaces are regional resource, as such there would be one workspace per hub (region)')
resource resLogAnalyticHub 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: 'la-hub-${parLocation}'
  location: parLocation
  properties: {
    sku: {
      name: parLogAnalyticsWorkspaceSkuName
      capacityReservationLevel: parLogAnalyticsWorkspaceSkuName == 'CapacityReservation' ? parLogAnalyticsWorkspaceCapacityReservationLevel : null
    }
    retentionInDays: parLogAnalyticsWorkspaceLogRetentionInDays
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
  scope: resLogAnalyticHub
  properties: {
    workspaceId: resLogAnalyticHub.id
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

// Outputs
output outLogAnalyticsWorkspaceName string = resLogAnalyticHub.name
output outLogAnalyticsWorkspaceId string = resLogAnalyticHub.id
