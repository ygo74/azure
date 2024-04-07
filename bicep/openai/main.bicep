@description('The location in which all resources should be deployed.')
param location string = resourceGroup().location

@description('This is the base name for each Azure resource name (6-8 chars)')
@minLength(6)
@maxLength(20)
param baseName string

@description('Public Network Access')
param publicNetworkAccess string = 'Disabled'


// ---- Log Analytics workspace ----
resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'log-${baseName}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}


// Deploy application insights and log analytics workspace
module appInsightsModule 'modules/applicationinsignts.bicep' = {
  name: 'appInsightsDeploy'
  params: {
    location: location
    baseName: baseName
    logWorkspaceName: logWorkspace.name
  }
}

// Deploy Azure OpenAI service with private endpoint and private DNS zone
module openaiModule 'modules/openai.bicep' = {
  name: 'openaiDeploy'
  params: {
    location: location
    baseName: baseName
    parPublicNetworkAccess: publicNetworkAccess
    logWorkspaceName: logWorkspace.name
  }
}

// Deploy the gpt 3.5 model within the Azure OpenAI service deployed above.
module openaiModels 'modules/openai-models.bicep' = {
  name: 'openaiModelsDeploy'
  params: {
    openaiName: openaiModule.outputs.openAiResourceName
  }
}
