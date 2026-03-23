// Azure AI Foundry Module
// Code to Cloud - Azure Essentials
// Lesson 11: Azure AI Foundry
//
// This module deploys the NEW Azure AI Foundry (March 2026):
// - Azure AI Services multi-service resource (kind: AIServices)
// - Application Insights for monitoring
// - Optional: Container Registry for hosted agents

@description('Azure region for AI resources')
param location string

@description('Tags to apply to resources')
param tags object

@description('Name prefix for AI Foundry resources')
param aiFoundryName string

@description('Enable hosted agents support (creates Container Registry)')
param enableHostedAgents bool = false

// ============================================================================
// LOG ANALYTICS WORKSPACE
// ============================================================================

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'log-${aiFoundryName}'
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// ============================================================================
// APPLICATION INSIGHTS
// ============================================================================

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-${aiFoundryName}'
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

// ============================================================================
// AZURE AI SERVICES (Foundry Resource)
// ============================================================================
// This is the NEW Foundry resource type (kind: AIServices)
// Provides multi-service AI capabilities including:
// - Azure OpenAI
// - Speech, Vision, Language services
// - Document Intelligence
// - Content Safety

resource aiServices 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: 'ai-${aiFoundryName}'
  location: location
  tags: tags
  kind: 'AIServices'
  sku: {
    name: 'S0' // Standard tier (required for AIServices)
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    customSubDomainName: 'ai-${aiFoundryName}'
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
    disableLocalAuth: false
  }
}

// ============================================================================
// CONTAINER REGISTRY (for Hosted Agents)
// ============================================================================

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = if (enableHostedAgents) {
  name: 'cr${uniqueString(resourceGroup().id, aiFoundryName)}'
  location: location
  tags: tags
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
    publicNetworkAccess: 'Enabled'
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

output aiServicesName string = aiServices.name
output aiServicesId string = aiServices.id
output aiServicesEndpoint string = aiServices.properties.endpoint
output aiServicesPrincipalId string = aiServices.identity.principalId
output applicationInsightsId string = applicationInsights.id
output applicationInsightsConnectionString string = applicationInsights.properties.ConnectionString
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
output containerRegistryName string = enableHostedAgents ? containerRegistry.name : ''
output containerRegistryLoginServer string = enableHostedAgents ? containerRegistry.properties.loginServer : ''
