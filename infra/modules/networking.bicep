// Azure Networking Module
// Code to Cloud - Azure Essentials
// Lesson 04: Networking Services

@description('Azure region for networking resources')
param location string

@description('Tags to apply to resources')
param tags object

@description('Name of the virtual network')
param vnetName string

@description('Address space for the virtual network')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Address prefix for the web subnet')
param webSubnetPrefix string = '10.0.1.0/24'

@description('Address prefix for the app subnet')
param appSubnetPrefix string = '10.0.2.0/24'

@description('Address prefix for the data subnet')
param dataSubnetPrefix string = '10.0.3.0/24'

// ============================================================================
// NETWORK SECURITY GROUPS
// ============================================================================

resource webNsg 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: 'nsg-web'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowHTTP'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowHTTPS'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource appNsg 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: 'nsg-app'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowWebSubnet'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '8080'
          sourceAddressPrefix: webSubnetPrefix
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource dataNsg 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: 'nsg-data'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowAppSubnet'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '1433'
          sourceAddressPrefix: appSubnetPrefix
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// ============================================================================
// VIRTUAL NETWORK
// ============================================================================

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'snet-web'
        properties: {
          addressPrefix: webSubnetPrefix
          networkSecurityGroup: {
            id: webNsg.id
          }
        }
      }
      {
        name: 'snet-app'
        properties: {
          addressPrefix: appSubnetPrefix
          networkSecurityGroup: {
            id: appNsg.id
          }
        }
      }
      {
        name: 'snet-data'
        properties: {
          addressPrefix: dataSubnetPrefix
          networkSecurityGroup: {
            id: dataNsg.id
          }
        }
      }
    ]
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

output vnetName string = virtualNetwork.name
output vnetId string = virtualNetwork.id
output webSubnetId string = virtualNetwork.properties.subnets[0].id
output appSubnetId string = virtualNetwork.properties.subnets[1].id
output dataSubnetId string = virtualNetwork.properties.subnets[2].id
