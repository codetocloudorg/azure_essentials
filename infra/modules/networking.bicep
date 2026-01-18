// ============================================================================
// Azure Networking Module
// ============================================================================
// Code to Cloud | www.codetocloud.io
// Lesson 04: Networking Services
//
// WHAT THIS CREATES:
//   - Virtual Network (VNet) with /16 address space (65,536 IPs)
//   - Three subnets following the 3-tier architecture pattern:
//       • Web tier   (/24 = 256 IPs) - Public-facing resources
//       • App tier   (/24 = 256 IPs) - Application logic layer
//       • Data tier  (/24 = 256 IPs) - Database servers
//   - Network Security Groups (NSGs) for each subnet
//
// COST: Free (VNets, subnets, and NSGs have no cost)
//
// ARCHITECTURE PATTERN: 3-Tier Web Application
//   ┌─────────────────┐
//   │    Internet     │
//   └────────┬────────┘
//            │ HTTPS (443), HTTP (80)
//   ┌────────▼────────┐
//   │   Web Subnet    │  <- Front-end servers, load balancers
//   └────────┬────────┘
//            │ Port 8080 (internal)
//   ┌────────▼────────┐
//   │   App Subnet    │  <- API servers, business logic
//   └────────┬────────┘
//            │ Port 1433 (SQL)
//   ┌────────▼────────┐
//   │  Data Subnet    │  <- Databases, storage
//   └─────────────────┘
//
// TRAINER TIP: Explain the principle of least privilege -
// each NSG only allows the traffic it needs.
// ============================================================================

// ============================================================================
// PARAMETERS - Customizable inputs for the module
// ============================================================================

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
// NETWORK SECURITY GROUPS (NSGs)
// ============================================================================
// NSGs are stateful firewalls that filter traffic based on 5-tuple rules:
//   - Source IP/Port
//   - Destination IP/Port
//   - Protocol (TCP/UDP/ICMP/*)
//
// RULE PRIORITY: Lower number = Higher priority (100 processed before 200)
// RULE DIRECTION: Inbound = Traffic coming IN, Outbound = Traffic going OUT
// DEFAULT RULES: All VNet-to-VNet allowed, all internet outbound allowed,
//                all internet inbound denied (priority 65500)

// ----------------------------------------------------------------------------
// Web Tier NSG - Allows HTTP/HTTPS from internet
// ----------------------------------------------------------------------------
// This is the public-facing tier where web servers and load balancers live.
// Rules allow web traffic from any source (the internet).

resource webNsg 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: 'nsg-web'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowHTTP'
        properties: {
          priority: 100  // First rule to evaluate
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'       // Any source port (client ephemeral port)
          destinationPortRange: '80' // HTTP
          sourceAddressPrefix: '*'   // Any source (internet)
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
          destinationPortRange: '443' // HTTPS (encrypted)
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// ----------------------------------------------------------------------------
// App Tier NSG - Only allows traffic from Web tier
// ----------------------------------------------------------------------------
// Application servers are not directly accessible from internet.
// Only the web tier can reach them on port 8080.

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
          destinationPortRange: '8080'          // Application port
          sourceAddressPrefix: webSubnetPrefix  // ONLY from web subnet!
          destinationAddressPrefix: '*'
        }
      }
      // All other inbound traffic is denied by default (rule priority 65500)
    ]
  }
}

// ----------------------------------------------------------------------------
// Data Tier NSG - Only allows traffic from App tier
// ----------------------------------------------------------------------------
// Databases should NEVER be directly accessible from internet or web tier.
// Only application servers can connect, limiting attack surface.

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
          destinationPortRange: '1433'          // SQL Server port
          sourceAddressPrefix: appSubnetPrefix  // ONLY from app subnet!
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// ============================================================================
// VIRTUAL NETWORK (VNet)
// ============================================================================
// A VNet is your private network in Azure - all resources inside can
// communicate with each other by default.
//
// ADDRESS SPACE: 10.0.0.0/16 provides 65,536 private IP addresses
// This is a Class A private range per RFC 1918 (10.0.0.0 - 10.255.255.255)
//
// SUBNET DESIGN:
//   - /16 for VNet = Room to grow (256 possible /24 subnets)
//   - /24 for each subnet = 251 usable IPs per subnet
//     (Azure reserves 5 IPs per subnet for infrastructure)

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix  // 10.0.0.0/16 - Our private address space
      ]
    }
    subnets: [
      {
        name: 'snet-web'  // Web tier subnet
        properties: {
          addressPrefix: webSubnetPrefix  // 10.0.1.0/24
          networkSecurityGroup: {
            id: webNsg.id  // Attach the web NSG
          }
        }
      }
      {
        name: 'snet-app'  // Application tier subnet
        properties: {
          addressPrefix: appSubnetPrefix  // 10.0.2.0/24
          networkSecurityGroup: {
            id: appNsg.id  // Attach the app NSG
          }
        }
      }
      {
        name: 'snet-data'  // Data tier subnet
        properties: {
          addressPrefix: dataSubnetPrefix  // 10.0.3.0/24
          networkSecurityGroup: {
            id: dataNsg.id  // Attach the data NSG
          }
        }
      }
    ]
  }
}

// ============================================================================
// OUTPUTS - Values returned to the calling template
// ============================================================================
// Subnet IDs are needed when deploying VMs, App Services, or other resources
// that need to join a subnet.

output vnetName string = virtualNetwork.name
output vnetId string = virtualNetwork.id

// Subnet resource IDs for resource deployment
output webSubnetId string = virtualNetwork.properties.subnets[0].id
output appSubnetId string = virtualNetwork.properties.subnets[1].id
output dataSubnetId string = virtualNetwork.properties.subnets[2].id
