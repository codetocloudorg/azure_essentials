// Azure Compute (Windows) Module
// Code to Cloud - Azure Essentials
// Lesson 05: Compute Services - Windows

@description('Azure region for compute resources')
param location string

@description('Tags to apply to resources')
param tags object

@description('Name of the App Service Plan')
param appServicePlanName string

@description('Name of the Web App')
param webAppName string

@description('App Service Plan SKU')
@allowed([
  'F1'
  'B1'
  'B2'
  'S1'
  'P1v2'
])
param appServicePlanSku string = 'F1'

// ============================================================================
// APP SERVICE PLAN
// ============================================================================

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  sku: {
    name: appServicePlanSku
    capacity: 1
  }
  properties: {
    reserved: false // false = Windows, true = Linux
  }
}

// ============================================================================
// WEB APP
// ============================================================================

resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: webAppName
  location: location
  tags: union(tags, {
    'azd-service-name': 'web'
  })
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      http20Enabled: true
      netFrameworkVersion: 'v8.0'
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: 'dotnet'
        }
      ]
    }
  }
}

// Application settings
resource webAppSettings 'Microsoft.Web/sites/config@2023-12-01' = {
  parent: webApp
  name: 'appsettings'
  properties: {
    WEBSITE_RUN_FROM_PACKAGE: '1'
    ASPNETCORE_ENVIRONMENT: 'Production'
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

output appServicePlanId string = appServicePlan.id
output appServicePlanName string = appServicePlan.name
output webAppName string = webApp.name
output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
output webAppPrincipalId string = webApp.identity.?principalId ?? ''
