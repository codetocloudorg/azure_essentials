// Azure Essentials - Main Infrastructure Template
// Code to Cloud
// This template orchestrates all Azure resources for the training course
// Each lesson deploys to its own resource group for clarity

targetScope = 'subscription'

// ============================================================================
// PARAMETERS
// ============================================================================

@description('Name of the environment (used for resource naming)')
@minLength(1)
@maxLength(64)
param environmentName string

@description('Primary location for all resources - Top 5 North America regions with best free tier capacity')
@allowed([
  'eastus'
  'eastus2'
  'westus2'
  'centralus'
  'canadacentral'
])
param location string

@description('Optional: Specific lesson number to deploy. Leave empty for full deployment.')
@allowed(['', '03', '04', '05', '06', '07', '08', '09', '11'])
param lessonNumber string = ''

@description('App Service Plan SKU. Use B1 if your subscription has no F1 quota.')
@allowed(['F1', 'B1'])
param appServicePlanSku string = 'B1'

@description('Admin password for Lesson 05 Windows VM. Must be 12+ chars with uppercase, lowercase, number, and special char.')
@secure()
param windowsAdminPassword string = ''

@description('SSH public key for Lesson 06 Linux VM. Generate with: ssh-keygen -t rsa -b 4096')
@secure()
param sshPublicKey string = ''

@description('Tags to apply to all resources')
param tags object = {}

// ============================================================================
// VARIABLES
// ============================================================================

var abbrs = loadJsonContent('abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

var defaultTags = union(tags, {
  azdEnvName: environmentName
  course: 'azure-essentials'
  owner: 'code-to-cloud'
})

// Determine which resources to deploy based on lesson number
// Note: Lesson 02 (Management Groups) is deployed separately via Azure CLI at tenant scope
var deployAll = empty(lessonNumber)
var deployStorage = deployAll || lessonNumber == '03'
var deployNetworking = deployAll || lessonNumber == '04'
var deployComputeWindows = deployAll || lessonNumber == '05'
var deployLinuxK8s = deployAll || lessonNumber == '06'
var deployContainers = deployAll || lessonNumber == '07'
var deployServerless = deployAll || lessonNumber == '08'
var deployDatabase = deployAll || lessonNumber == '09'
var deployAI = deployAll || lessonNumber == '11'

// ============================================================================
// RESOURCE GROUPS - One per lesson for clarity
// ============================================================================

// Lesson 03: Storage Services
resource rgStorage 'Microsoft.Resources/resourceGroups@2024-03-01' = if (deployStorage) {
  name: 'rg-${environmentName}-lesson03-storage'
  location: location
  tags: union(defaultTags, { lesson: '03-storage-services' })
}

// Lesson 04: Networking
resource rgNetworking 'Microsoft.Resources/resourceGroups@2024-03-01' = if (deployNetworking) {
  name: 'rg-${environmentName}-lesson04-networking'
  location: location
  tags: union(defaultTags, { lesson: '04-networking' })
}

// Lesson 05: Compute (Windows)
resource rgCompute 'Microsoft.Resources/resourceGroups@2024-03-01' = if (deployComputeWindows) {
  name: 'rg-${environmentName}-lesson05-compute'
  location: location
  tags: union(defaultTags, { lesson: '05-compute-windows' })
}

// Lesson 06: Linux & Kubernetes
resource rgLinuxK8s 'Microsoft.Resources/resourceGroups@2024-03-01' = if (deployLinuxK8s) {
  name: 'rg-${environmentName}-lesson06-linux-k8s'
  location: location
  tags: union(defaultTags, { lesson: '06-linux-kubernetes' })
}

// Lesson 07: Container Services
resource rgContainers 'Microsoft.Resources/resourceGroups@2024-03-01' = if (deployContainers) {
  name: 'rg-${environmentName}-lesson07-containers'
  location: location
  tags: union(defaultTags, { lesson: '07-container-services' })
}

// Lesson 08: Serverless
resource rgServerless 'Microsoft.Resources/resourceGroups@2024-03-01' = if (deployServerless) {
  name: 'rg-${environmentName}-lesson08-serverless'
  location: location
  tags: union(defaultTags, { lesson: '08-serverless' })
}

// Lesson 09: Database Services
resource rgDatabase 'Microsoft.Resources/resourceGroups@2024-03-01' = if (deployDatabase) {
  name: 'rg-${environmentName}-lesson09-database'
  location: location
  tags: union(defaultTags, { lesson: '09-database-services' })
}

// Lesson 11: AI Foundry
resource rgAI 'Microsoft.Resources/resourceGroups@2024-03-01' = if (deployAI) {
  name: 'rg-${environmentName}-lesson11-ai-foundry'
  location: location
  tags: union(defaultTags, { lesson: '11-ai-foundry' })
}

// ============================================================================
// MODULES - Each deploys to its own resource group
// ============================================================================

// Lesson 03: Storage Services
module storage './modules/storage.bicep' = if (deployStorage) {
  name: 'storage-${resourceToken}'
  scope: rgStorage
  params: {
    location: location
    tags: defaultTags
    storageAccountName: '${abbrs.storageAccount}${resourceToken}'
  }
}

// Lesson 04: Networking Services
module networking './modules/networking.bicep' = if (deployNetworking) {
  name: 'networking-${resourceToken}'
  scope: rgNetworking
  params: {
    location: location
    tags: defaultTags
    vnetName: '${abbrs.virtualNetwork}${environmentName}'
  }
}

// Lesson 05: Windows Compute
module computeWindows './modules/compute-windows.bicep' = if (deployComputeWindows) {
  name: 'compute-windows-${resourceToken}'
  scope: rgCompute
  params: {
    location: location
    tags: defaultTags
    appServicePlanName: '${abbrs.appServicePlan}${environmentName}'
    webAppName: '${abbrs.webApp}${resourceToken}'
    appServicePlanSku: appServicePlanSku
    vmName: 'vm-${environmentName}-win'
    adminPassword: windowsAdminPassword
  }
}

// Lesson 07: Container Services (ACR + AKS)
module containers './modules/container-registry.bicep' = if (deployContainers) {
  name: 'containers-${resourceToken}'
  scope: rgContainers
  params: {
    location: location
    tags: defaultTags
    acrName: '${abbrs.containerRegistry}${resourceToken}'
    aksName: 'aks-${environmentName}-${resourceToken}'
  }
}

// Lesson 08: Serverless (Azure Functions)
module serverless './modules/functions.bicep' = if (deployServerless) {
  name: 'serverless-${resourceToken}'
  scope: rgServerless
  params: {
    location: location
    tags: defaultTags
    functionAppName: '${abbrs.functionApp}${resourceToken}'
    storageAccountName: '${abbrs.storageAccount}func${resourceToken}'
  }
}

// Lesson 09: Database Services (Cosmos DB)
module database './modules/cosmosdb.bicep' = if (deployDatabase) {
  name: 'database-${resourceToken}'
  scope: rgDatabase
  params: {
    location: location
    tags: defaultTags
    cosmosDbAccountName: '${abbrs.cosmosDb}${resourceToken}'
  }
}

// Lesson 11: AI Foundry
module ai './modules/ai-foundry.bicep' = if (deployAI) {
  name: 'ai-${resourceToken}'
  scope: rgAI
  params: {
    location: location
    tags: defaultTags
    aiHubName: '${abbrs.aiHub}${environmentName}'
  }
}

// Lesson 06: Linux VM with MicroK8s
module linuxK8s './modules/linux-microk8s.bicep' = if (deployLinuxK8s) {
  name: 'linux-k8s-${resourceToken}'
  scope: rgLinuxK8s
  params: {
    location: location
    tags: defaultTags
    namePrefix: environmentName
    adminUsername: 'azureuser'
    sshPublicKey: sshPublicKey
    vmSize: 'Standard_B1s'
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

output AZURE_LOCATION string = location

// Resource Group outputs - shows which resource groups were created
// Note: Lesson 02 (Management Groups) has no outputs here - deployed separately at tenant scope
output RESOURCE_GROUP_STORAGE string = rgStorage.?name ?? ''
output RESOURCE_GROUP_NETWORKING string = rgNetworking.?name ?? ''
output RESOURCE_GROUP_COMPUTE string = rgCompute.?name ?? ''
output RESOURCE_GROUP_LINUX_K8S string = rgLinuxK8s.?name ?? ''
output RESOURCE_GROUP_CONTAINERS string = rgContainers.?name ?? ''
output RESOURCE_GROUP_SERVERLESS string = rgServerless.?name ?? ''
output RESOURCE_GROUP_DATABASE string = rgDatabase.?name ?? ''
output RESOURCE_GROUP_AI string = rgAI.?name ?? ''

// Storage outputs
output STORAGE_ACCOUNT_NAME string = storage.?outputs.?storageAccountName ?? ''
output STORAGE_BLOB_ENDPOINT string = storage.?outputs.?blobEndpoint ?? ''

// Networking outputs
output VNET_NAME string = networking.?outputs.?vnetName ?? ''
output VNET_ID string = networking.?outputs.?vnetId ?? ''

// Compute outputs
output WEB_APP_NAME string = computeWindows.?outputs.?webAppName ?? ''
output WEB_APP_URL string = computeWindows.?outputs.?webAppUrl ?? ''
output WINDOWS_VM_NAME string = computeWindows.?outputs.?vmName ?? ''
output WINDOWS_VM_PUBLIC_IP string = computeWindows.?outputs.?vmPublicIp ?? ''
output WINDOWS_VM_FQDN string = computeWindows.?outputs.?vmFqdn ?? ''
output WINDOWS_VM_RDP_COMMAND string = computeWindows.?outputs.?rdpCommand ?? ''

// Container outputs
output ACR_NAME string = containers.?outputs.?acrName ?? ''
output ACR_LOGIN_SERVER string = containers.?outputs.?acrLoginServer ?? ''

// Serverless outputs
output FUNCTION_APP_NAME string = serverless.?outputs.?functionAppName ?? ''
output FUNCTION_APP_URL string = serverless.?outputs.?functionAppUrl ?? ''

// Database outputs
output COSMOS_DB_ACCOUNT_NAME string = database.?outputs.?cosmosDbAccountName ?? ''
output COSMOS_DB_ENDPOINT string = database.?outputs.?cosmosDbEndpoint ?? ''

// AI outputs
output AI_HUB_NAME string = ai.?outputs.?aiHubName ?? ''

// Linux K8s VM outputs (Lesson 06)
output LINUX_K8S_VM_NAME string = linuxK8s.?outputs.?vmName ?? ''
output LINUX_K8S_PUBLIC_IP string = linuxK8s.?outputs.?publicIpAddress ?? ''
output LINUX_K8S_SSH_COMMAND string = linuxK8s.?outputs.?sshCommand ?? ''
output LINUX_K8S_DNS_FQDN string = linuxK8s.?outputs.?fqdn ?? ''
