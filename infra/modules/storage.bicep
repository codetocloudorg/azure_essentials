// Azure Storage Account Module
// Code to Cloud - Azure Essentials
// Lesson 03: Storage Services

@description('Azure region for the storage account')
param location string

@description('Tags to apply to resources')
param tags object

@description('Name of the storage account')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('Storage account SKU')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Standard_RAGRS'
])
param skuName string = 'Standard_LRS'

@description('Storage account kind')
@allowed([
  'StorageV2'
  'BlobStorage'
  'Storage'
])
param kind string = 'StorageV2'

// ============================================================================
// STORAGE ACCOUNT
// ============================================================================

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  kind: kind
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
        queue: {
          enabled: true
        }
        table: {
          enabled: true
        }
      }
    }
  }
}

// Blob service configuration
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

// Sample container for exercises
resource sampleContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'samples'
  properties: {
    publicAccess: 'None'
  }
}

// Queue service configuration
resource queueService 'Microsoft.Storage/storageAccounts/queueServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
}

// Sample queue for exercises
resource sampleQueue 'Microsoft.Storage/storageAccounts/queueServices/queues@2023-05-01' = {
  parent: queueService
  name: 'sample-messages'
}

// ============================================================================
// OUTPUTS
// ============================================================================

output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
output blobEndpoint string = storageAccount.properties.primaryEndpoints.blob
output queueEndpoint string = storageAccount.properties.primaryEndpoints.queue
output tableEndpoint string = storageAccount.properties.primaryEndpoints.table
output fileEndpoint string = storageAccount.properties.primaryEndpoints.file
