// Azure Management Groups Module
// Code to Cloud - Azure Essentials
// Lesson 02: Getting Started with Azure - Organizational Hierarchy Demo

targetScope = 'tenant'

@description('Environment name for naming resources')
param environmentName string

@description('Tags to apply to resources')
param tags object = {}

// ============================================================================
// MANAGEMENT GROUP HIERARCHY
// This creates a basic Azure Landing Zone style structure for demonstration
// ============================================================================

// Root Management Group (under Tenant Root Group)
resource rootMG 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: 'mg-${environmentName}-root'
  properties: {
    displayName: '${environmentName} - Organization Root'
    details: {}
  }
}

// Platform Management Group
resource platformMG 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: 'mg-${environmentName}-platform'
  properties: {
    displayName: 'Platform'
    details: {
      parent: {
        id: rootMG.id
      }
    }
  }
}

// Workloads Management Group
resource workloadsMG 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: 'mg-${environmentName}-workloads'
  properties: {
    displayName: 'Workloads'
    details: {
      parent: {
        id: rootMG.id
      }
    }
  }
}

// Sandbox Management Group (for learning/testing)
resource sandboxMG 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: 'mg-${environmentName}-sandbox'
  properties: {
    displayName: 'Sandbox'
    details: {
      parent: {
        id: rootMG.id
      }
    }
  }
}

// Identity (under Platform)
resource identityMG 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: 'mg-${environmentName}-identity'
  properties: {
    displayName: 'Identity'
    details: {
      parent: {
        id: platformMG.id
      }
    }
  }
}

// Connectivity (under Platform)
resource connectivityMG 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: 'mg-${environmentName}-connectivity'
  properties: {
    displayName: 'Connectivity'
    details: {
      parent: {
        id: platformMG.id
      }
    }
  }
}

// Management (under Platform)
resource managementMG 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: 'mg-${environmentName}-management'
  properties: {
    displayName: 'Management'
    details: {
      parent: {
        id: platformMG.id
      }
    }
  }
}

// Production (under Workloads)
resource prodMG 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: 'mg-${environmentName}-prod'
  properties: {
    displayName: 'Production'
    details: {
      parent: {
        id: workloadsMG.id
      }
    }
  }
}

// Non-Production (under Workloads)
resource nonprodMG 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: 'mg-${environmentName}-nonprod'
  properties: {
    displayName: 'Non-Production'
    details: {
      parent: {
        id: workloadsMG.id
      }
    }
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

output rootManagementGroupId string = rootMG.id
output rootManagementGroupName string = rootMG.name
output platformManagementGroupId string = platformMG.id
output workloadsManagementGroupId string = workloadsMG.id
output sandboxManagementGroupId string = sandboxMG.id
