// Azure Container Registry Module
// Code to Cloud - Azure Essentials
// Lesson 07: Container Services

@description('Azure region for container resources')
param location string

@description('Tags to apply to resources')
param tags object

@description('Name of the Azure Container Registry')
@minLength(5)
@maxLength(50)
param acrName string

@description('ACR SKU')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param acrSku string = 'Basic'

// ============================================================================
// CONTAINER REGISTRY
// ============================================================================

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: acrName
  location: location
  tags: tags
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: true
    publicNetworkAccess: 'Enabled'
    policies: {
      retentionPolicy: {
        status: 'disabled'
        days: 7
      }
    }
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

output acrName string = containerRegistry.name
output acrId string = containerRegistry.id
output acrLoginServer string = containerRegistry.properties.loginServer
