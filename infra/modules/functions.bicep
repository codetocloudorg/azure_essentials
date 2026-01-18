// ============================================================================
// Azure Functions Module
// ============================================================================
// Code to Cloud | www.codetocloud.io
// Lesson 08: Serverless Services
//
// WHAT THIS CREATES:
//   - Azure Function App (Consumption plan)
//   - Storage Account (required for function triggers/bindings)
//   - Application Insights (monitoring and logging)
//   - Log Analytics Workspace (centralized logs)
//
// COST MODEL (Consumption Plan):
//   - First 1 million executions/month: FREE
//   - First 400,000 GB-s compute/month: FREE
//   - After free tier: ~$0.20 per million executions
//   - Storage: ~$0.02/GB/month
//
// CONSUMPTION vs PREMIUM vs DEDICATED:
//   Consumption: Scale to zero, pay-per-execution, cold starts
//   Premium: Pre-warmed instances, VNet integration, no cold starts
//   Dedicated: App Service Plan, predictable pricing, always warm
//
// TRAINER TIP: Demonstrate cold start behavior vs warm instances
// ============================================================================

// ============================================================================
// PARAMETERS - Customizable inputs for the module
// ============================================================================

@description('Azure region for serverless resources')
param location string

@description('Tags to apply to resources')
param tags object

@description('Name of the Function App')
param functionAppName string

@description('Name of the storage account for the function')
param storageAccountName string

// ============================================================================
// STORAGE ACCOUNT (required for Functions)
// ============================================================================
// Azure Functions REQUIRES a storage account for:
//   - Trigger management (tracking execution state)
//   - Queue/Blob triggers (event sources)
//   - Durable Functions (orchestration state)
//   - Function code storage (when using Consumption plan)

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
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
// APPLICATION INSIGHTS - Monitoring & Performance Tracking
// ============================================================================
// Application Insights provides:
//   - Real-time monitoring of function executions
//   - Performance metrics (execution time, failures)
//   - Distributed tracing across services
//   - Custom event and metric logging
//
// Requires Log Analytics Workspace for data storage (newer model)

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'log-${functionAppName}'
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
  name: 'appi-${functionAppName}'
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

// ============================================================================
// APP SERVICE PLAN (Consumption/Dynamic)
// ============================================================================
// Y1 SKU = Consumption Plan (Serverless)
//   - Automatic scaling from 0 to many instances
//   - Pay only for execution time (GB-seconds)
//   - Maximum 10-minute execution timeout
//   - No reserved capacity (cold starts possible)

resource hostingPlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: 'asp-${functionAppName}'
  location: location
  tags: tags
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {}
}

// ============================================================================
// FUNCTION APP - The serverless compute resource
// ============================================================================
// This creates a Python 3.11 Function App with:
//   - HTTP trigger support (built-in)
//   - Storage triggers/bindings (via connection string)
//   - Application Insights integration (automatic logging)
//
// TRIGGER TYPES: HTTP, Timer, Blob, Queue, Event Hub, Cosmos DB, etc.

resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: functionAppName
  location: location
  tags: union(tags, {
    'azd-service-name': 'sample-function'
  })
  kind: 'functionapp'
  properties: {
    serverFarmId: hostingPlan.id
    httpsOnly: true
    siteConfig: {
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      pythonVersion: '3.11'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
      ]
    }
  }
}

// ============================================================================
// OUTPUTS - Values returned to the calling template
// ============================================================================
// Use these outputs to:
//   - Deploy code to the function app
//   - Configure monitoring dashboards
//   - Connect other services

output functionAppName string = functionApp.name
output functionAppId string = functionApp.id
output functionAppUrl string = 'https://${functionApp.properties.defaultHostName}'
output applicationInsightsName string = applicationInsights.name
output applicationInsightsConnectionString string = applicationInsights.properties.ConnectionString
