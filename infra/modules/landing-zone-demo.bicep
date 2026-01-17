// Azure Landing Zone Demo Module
// Code to Cloud - Azure Essentials
// Lesson 02: Getting Started - Azure Organizational Hierarchy Demo
//
// This creates resource groups that demonstrate Azure's organizational structure
// Note: Management Groups require elevated permissions, so we use RGs to illustrate

targetScope = 'subscription'

@description('Azure region for resources')
param location string

@description('Environment name prefix')
param environmentName string

// ============================================================================
// RESOURCE GROUPS - Simulating Management Group Hierarchy
// This demonstrates how organizations structure their Azure environment
// ============================================================================

var defaultTags = {
  project: 'Azure-Essentials'
  lesson: '02-landing-zone-demo'
}

// Platform - Identity
resource rgIdentity 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${environmentName}-lz-platform-identity'
  location: location
  tags: union(defaultTags, {
    hierarchy: 'Platform/Identity'
    purpose: 'Identity and access management resources'
    example: 'Azure AD, Key Vaults for secrets'
  })
}

// Platform - Connectivity
resource rgConnectivity 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${environmentName}-lz-platform-connectivity'
  location: location
  tags: union(defaultTags, {
    hierarchy: 'Platform/Connectivity'
    purpose: 'Network hub and connectivity resources'
    example: 'Hub VNet, Firewalls, VPN Gateways'
  })
}

// Platform - Management
resource rgManagement 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${environmentName}-lz-platform-management'
  location: location
  tags: union(defaultTags, {
    hierarchy: 'Platform/Management'
    purpose: 'Monitoring and management resources'
    example: 'Log Analytics, Azure Monitor'
  })
}

// Workloads - Production
resource rgProd 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${environmentName}-lz-workloads-prod'
  location: location
  tags: union(defaultTags, {
    hierarchy: 'Workloads/Production'
    purpose: 'Production application workloads'
    environment: 'production'
  })
}

// Workloads - Non-Production
resource rgNonProd 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${environmentName}-lz-workloads-nonprod'
  location: location
  tags: union(defaultTags, {
    hierarchy: 'Workloads/Non-Production'
    purpose: 'Development and testing workloads'
    environment: 'development'
  })
}

// Sandbox - Learning
resource rgSandbox 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${environmentName}-lz-sandbox-learning'
  location: location
  tags: union(defaultTags, {
    hierarchy: 'Sandbox/Learning'
    purpose: 'Learning and experimentation'
    environment: 'sandbox'
  })
}

// ============================================================================
// OUTPUTS
// ============================================================================

output identityResourceGroup string = rgIdentity.name
output connectivityResourceGroup string = rgConnectivity.name
output managementResourceGroup string = rgManagement.name
output productionResourceGroup string = rgProd.name
output nonProductionResourceGroup string = rgNonProd.name
output sandboxResourceGroup string = rgSandbox.name

output hierarchyDescription string = '''
Azure Landing Zone Structure Created:
├── Platform
│   ├── Identity (Azure AD, Key Vaults)
│   ├── Connectivity (Hub VNet, Firewalls)
│   └── Management (Monitoring, Logging)
├── Workloads
│   ├── Production (Live apps)
│   └── Non-Production (Dev/Test)
└── Sandbox
    └── Learning (Experimentation)
'''
