// Azure AI Foundry Module
// Code to Cloud - Azure Essentials
// Lesson 11: Azure AI Foundry

@description('Azure region for AI resources')
param location string

@description('Tags to apply to resources')
param tags object

@description('Name of the AI Hub')
param aiHubName string

// ============================================================================
// STORAGE ACCOUNT (for AI Hub)
// ============================================================================

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'st${uniqueString(resourceGroup().id, aiHubName)}'
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}

// ============================================================================
// KEY VAULT (for AI Hub)
// ============================================================================

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: 'kv-${uniqueString(resourceGroup().id, aiHubName)}'
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
  }
}

// ============================================================================
// APPLICATION INSIGHTS
// ============================================================================

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'log-${aiHubName}'
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-${aiHubName}'
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

// ============================================================================
// AI HUB
// ============================================================================

resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-04-01' = {
  name: aiHubName
  location: location
  tags: tags
  kind: 'Hub'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: 'Azure Essentials AI Hub'
    description: 'AI Hub for Azure Essentials training course'
    storageAccount: storageAccount.id
    keyVault: keyVault.id
    applicationInsights: applicationInsights.id
    publicNetworkAccess: 'Enabled'
  }
}

// ============================================================================
// AI PROJECT
// ============================================================================

resource aiProject 'Microsoft.MachineLearningServices/workspaces@2024-04-01' = {
  name: '${aiHubName}-project'
  location: location
  tags: tags
  kind: 'Project'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: 'Azure Essentials AI Project'
    description: 'AI Project for chatbot development exercises'
    hubResourceId: aiHub.id
    publicNetworkAccess: 'Enabled'
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

output aiHubName string = aiHub.name
output aiHubId string = aiHub.id
output aiProjectName string = aiProject.name
output aiProjectId string = aiProject.id
