// Azure Cosmos DB Module
// Code to Cloud - Azure Essentials
// Lesson 09: Database and Data Services

@description('Azure region for database resources')
param location string

@description('Tags to apply to resources')
param tags object

@description('Name of the Cosmos DB account')
@minLength(3)
@maxLength(44)
param cosmosDbAccountName string

@description('Use serverless capacity mode (recommended for learning - pay only for what you use)')
param useServerless bool = true

// ============================================================================
// COSMOS DB ACCOUNT
// Note: Using Serverless capacity mode which is most cost-effective for learning
// Free tier is NOT compatible with Serverless, so we use Serverless for pay-per-use
// ============================================================================

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' = {
  name: cosmosDbAccountName
  location: location
  tags: tags
  kind: 'GlobalDocumentDB'
  properties: {
    // Note: enableFreeTier cannot be combined with Serverless
    // Serverless is better for learning - you only pay for operations performed
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    capabilities: useServerless
      ? [
          {
            name: 'EnableServerless'
          }
        ]
      : []
    backupPolicy: {
      type: 'Continuous'
      continuousModeProperties: {
        tier: 'Continuous7Days'
      }
    }
  }
}

// ============================================================================
// DATABASE
// ============================================================================

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-05-15' = {
  parent: cosmosDbAccount
  name: 'azure-essentials'
  properties: {
    resource: {
      id: 'azure-essentials'
    }
  }
}

// ============================================================================
// CONTAINER
// ============================================================================

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-05-15' = {
  parent: database
  name: 'items'
  properties: {
    resource: {
      id: 'items'
      partitionKey: {
        paths: [
          '/category'
        ]
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/_etag/?'
          }
        ]
      }
    }
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

output cosmosDbAccountName string = cosmosDbAccount.name
output cosmosDbAccountId string = cosmosDbAccount.id
output cosmosDbEndpoint string = cosmosDbAccount.properties.documentEndpoint
output databaseName string = database.name
output containerName string = container.name
