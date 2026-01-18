// ============================================================================
// Azure Cosmos DB Module
// ============================================================================
// Code to Cloud | www.codetocloud.io
// Lesson 09: Database and Data Services
//
// WHAT THIS CREATES:
//   - Cosmos DB Account (Serverless capacity mode)
//   - SQL API Database (azure-essentials)
//   - Container with partition key (items)
//
// COST MODEL (Serverless):
//   - Pay per Request Unit (RU) consumed
//   - First 25GB storage: included
//   - ~$0.25 per million RUs
//   - No minimum charge when idle
//
// SERVERLESS vs PROVISIONED:
//   Serverless: Pay-per-request, auto-scale, great for dev/test
//   Provisioned: Reserved throughput, predictable cost, better for prod
//
// CONSISTENCY LEVELS (from strongest to weakest):
//   1. Strong: Linearizable reads (highest latency)
//   2. Bounded Staleness: Ordered, bounded lag
//   3. Session: Consistent within session (DEFAULT - good balance)
//   4. Consistent Prefix: Ordered, no staleness guarantee
//   5. Eventual: Fastest, may read stale data
//
// TRAINER TIP: Session consistency is the most commonly used because
// it guarantees read-your-writes for the same session.
// ============================================================================

// ============================================================================
// PARAMETERS - Customizable inputs for the module
// ============================================================================

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
// COSMOS DB ACCOUNT - Global NoSQL database
// ============================================================================
// Cosmos DB is a globally distributed, multi-model database:
//   - Multi-region replication with automatic failover
//   - Multiple APIs: SQL (default), MongoDB, Cassandra, Gremlin, Table
//   - 99.999% read availability SLA (multi-region)
//
// SERVERLESS MODE: Best for learning - no charges when idle

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' = {
  name: cosmosDbAccountName
  location: location
  tags: tags
  kind: 'GlobalDocumentDB'  // SQL API (not MongoDB or other)
  properties: {
    databaseAccountOfferType: 'Standard'

    // Session consistency = Read your own writes (good balance of consistency/perf)
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }

    // Single region deployment (add more locations for geo-replication)
    locations: [
      {
        locationName: location
        failoverPriority: 0      // Primary region
        isZoneRedundant: false   // Zone redundancy costs extra
      }
    ]

    // Enable Serverless mode for pay-per-request billing
    capabilities: useServerless
      ? [
          {
            name: 'EnableServerless'
          }
        ]
      : []

    // Continuous backup allows point-in-time restore
    backupPolicy: {
      type: 'Continuous'
      continuousModeProperties: {
        tier: 'Continuous7Days'  // 7-day retention (30 days available)
      }
    }
  }
}

// ============================================================================
// DATABASE - Logical container for collections
// ============================================================================
// A Cosmos DB account can have multiple databases
// Databases don't consume RUs directly - containers do

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
// CONTAINER - Where your data lives
// ============================================================================
// Containers are similar to tables in SQL databases.
// PARTITION KEY is crucial for scalability:
//   - Choose a property with high cardinality (many unique values)
//   - Common patterns: /userId, /tenantId, /category
//   - Data with same partition key lives on same physical partition

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-05-15' = {
  parent: database
  name: 'items'
  properties: {
    resource: {
      id: 'items'
      partitionKey: {
        paths: [
          '/category'  // Partition by category (e.g., "products", "orders")
        ]
        kind: 'Hash'   // Hash partitioning for even distribution
      }
      indexingPolicy: {
        indexingMode: 'consistent'  // Index updates are synchronous
        includedPaths: [
          {
            path: '/*'  // Index all properties (good for queries)
          }
        ]
        excludedPaths: [
          {
            path: '/_etag/?'  // Exclude system properties
          }
        ]
      }
    }
  }
}

// ============================================================================
// OUTPUTS - Values returned to the calling template
// ============================================================================
// Use these values to connect your application to Cosmos DB

output cosmosDbAccountName string = cosmosDbAccount.name
output cosmosDbAccountId string = cosmosDbAccount.id
output cosmosDbEndpoint string = cosmosDbAccount.properties.documentEndpoint
output databaseName string = database.name
output containerName string = container.name
