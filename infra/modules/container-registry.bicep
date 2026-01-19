// ============================================================================
// Azure Container Services Module (ACR + AKS)
// ============================================================================
// Code to Cloud | www.codetocloud.io
// Lesson 07: Container Services
//
// WHAT THIS CREATES:
//   - Azure Container Registry (ACR)
//   - Azure Kubernetes Service (AKS) cluster
//
// COST ESTIMATE:
//   ACR Basic:  ~$5/month
//   AKS (1 node Standard_B2s): ~$30/month
//   Total: ~$35/month
//
// NOTE: After deployment, use Azure CLI to:
//   1. Build container: az acr build --registry <acr> --image hello:v1 .
//   2. Get credentials: az aks get-credentials --name <aks> --resource-group <rg>
//   3. Deploy app:      kubectl create deployment hello --image=<acr>.azurecr.io/hello:v1
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

@description('Name of the AKS cluster')
param aksName string

@description('ACR SKU')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param acrSku string = 'Basic'

@description('Number of AKS nodes')
@minValue(1)
@maxValue(10)
param aksNodeCount int = 1

@description('AKS node VM size')
param aksNodeVmSize string = 'Standard_B2s'

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
output aksName string = aksCluster.name
output aksId string = aksCluster.id
output aksFqdn string = aksCluster.properties.fqdn

// ============================================================================
// AZURE KUBERNETES SERVICE (AKS)
// ============================================================================
// Managed Kubernetes cluster for container orchestration.
//
// WHAT YOU PAY FOR:           WHAT AZURE MANAGES (FREE):
//   - Worker node VMs           - Control plane
//   - Storage for containers    - API server
//   - Network egress            - etcd cluster + upgrades

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: aksName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: aksName
    kubernetesVersion: '1.33'
    
    agentPoolProfiles: [
      {
        name: 'nodepool1'
        count: aksNodeCount
        vmSize: aksNodeVmSize
        osType: 'Linux'
        mode: 'System'
        enableAutoScaling: false
      }
    ]
    
    networkProfile: {
      networkPlugin: 'azure'
      loadBalancerSku: 'standard'
    }
  }
}

// Role assignment to allow AKS to pull from ACR
resource acrPullRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistry.id, aksCluster.id, 'acrpull')
  scope: containerRegistry
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // AcrPull
    principalId: aksCluster.properties.identityProfile.kubeletidentity.objectId
    principalType: 'ServicePrincipal'
  }
}
