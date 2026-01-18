// ============================================================================
// Azure Container Registry Module
// ============================================================================
// Code to Cloud | www.codetocloud.io
// Lesson 07: Container Services
//
// WHAT THIS CREATES:
//   - Azure Container Registry (ACR)
//   - Private Docker registry for your container images
//
// COST BY SKU:
//   Basic:    ~$5/month,  10GB storage, 2 webhooks
//   Standard: ~$20/month, 100GB storage, 10 webhooks, geo-replication
//   Premium:  ~$50/month, 500GB storage, 500 webhooks, firewall, private link
//
// COMMON WORKFLOWS:
//   1. Build locally → Push to ACR → Pull from AKS/ACI/App Service
//   2. ACR Tasks → Build in cloud → Auto-deploy on commit
//
// TRAINER TIP: Demonstrate the difference between
// az acr build (build in cloud) vs docker push (push local image)
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
//   - Azure Kubernetes Service (AKS)
//   - Azure Container Instances (ACI)
//   - Azure App Service (Web App for Containers)
//   - Azure Functions (custom containers)
//
// AUTHENTICATION OPTIONS:
//   - Admin user (enabled here for simplicity)
//   - Service Principal
//   - Managed Identity (recommended for production)
//   - Azure AD token

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
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
// Use loginServer to tag and push images:
//   docker tag myapp:v1 {loginServer}/myapp:v1
//   docker push {loginServer}/myapp:v1

output acrName string = containerRegistry.name
output acrId string = containerRegistry.id
output acrLoginServer string = containerRegistry.properties.loginServer
