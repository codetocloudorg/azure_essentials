// ============================================================================
// Azure Container Services Module (ACR + Container Apps)
// ============================================================================
// Code to Cloud | www.codetocloud.io
// Lesson 07: Container Services
//
// WHAT THIS CREATES:
//   - Azure Container Registry (ACR)
//   - Azure Container Apps Environment
//
// COST ESTIMATE:
//   ACR Basic:  ~$5/month
//   Container Apps: ~$0 at low traffic (consumption plan)
//   Total: ~$5/month
//
// NOTE: After deployment, use Azure CLI to:
//   1. Build container: az acr build --registry <acr> --image hello:v1 .
//   2. Deploy app:      az containerapp create --name <app> --environment <env> --image <acr>.azurecr.io/hello:v1
// ============================================================================

// ============================================================================
// PARAMETERS - Customizable inputs for the module
// ============================================================================

@description('Azure region for container resources')
param location string

@description('Tags to apply to resources')
param tags object

@description('Name of the Azure Container Registry')
@minLength(5)
@maxLength(50)
param acrName string

@description('Name of the Container Apps Environment')
param containerAppsEnvName string

@description('ACR SKU')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param acrSku string = 'Basic'

// ============================================================================
// CONTAINER REGISTRY - Private Docker registry
// ============================================================================
// ACR stores and manages container images for:
// ACR stores and manages container images for:
//   - Azure Container Apps
//   - Azure Container Instances (ACI)
//   - Azure App Service (Web App for Containers)
//   - Azure Functions (custom containers)
//   - Azure Kubernetes Service (AKS)
//
// AUTHENTICATION OPTIONS:
//   - Admin user (enabled here for simplicity)
//   - Service Principal
//   - Managed Identity (recommended for production)
//   - Azure AD token

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: acrName
  location: location
  tags: tags
  sku: {
    name: acrSku  // Basic is sufficient for learning
  }
  properties: {
    // Admin user provides username/password access
    // For production, use managed identity instead
    adminUserEnabled: true

    // Allow access from internet (use Private Link in production)
    publicNetworkAccess: 'Enabled'

    policies: {
      // Image retention policy (Premium SKU only can enable)
      retentionPolicy: {
        status: 'disabled'
        days: 7
      }
    }
  }
}

// ============================================================================
// OUTPUTS - Values returned to the calling template
// ============================================================================

output acrName string = containerRegistry.name
output acrId string = containerRegistry.id
output acrLoginServer string = containerRegistry.properties.loginServer
output containerAppsEnvName string = containerAppsEnvironment.name
output containerAppsEnvId string = containerAppsEnvironment.id

// ============================================================================
// AZURE CONTAINER APPS ENVIRONMENT
// ============================================================================
// Serverless container platform — no clusters to manage.
//
// WHAT YOU PAY FOR:           WHAT AZURE MANAGES (FREE):
//   - vCPU/memory per request   - Infrastructure
//   - ~$0 at low traffic        - Scaling
//   - Consumption plan          - HTTPS/ingress

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: containerAppsEnvName
  location: location
  tags: tags
  properties: {
    zoneRedundant: false
  }
}
