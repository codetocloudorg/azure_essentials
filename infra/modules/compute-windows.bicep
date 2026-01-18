// ============================================================================
// Azure Compute (Windows) Module
// ============================================================================
// Code to Cloud | www.codetocloud.io
// Lesson 05: Compute Services - Windows
//
// WHAT THIS CREATES:
//   - Windows Server 2022 VM with RDP access
//   - App Service Plan (PaaS web hosting)
//   - Web App for .NET applications
//   - Auto-shutdown schedule (saves costs during training)
//
// COST BREAKDOWN:
//   VM (Standard_B2s):     ~$30-40/month (pay-per-hour when running)
//   App Service (F1):      Free (1GB RAM, 60 CPU min/day)
//   Public IP (Standard):  ~$3/month
//   Managed Disk (128GB):  ~$5/month
//
// AUTO-SHUTDOWN: VM shuts down daily at 7PM UTC to save costs
// TRAINER TIP: Show how to start/stop VMs vs delete/recreate
//
// VM ACCESS: RDP (Remote Desktop Protocol) on port 3389
//   Command: mstsc /v:{public-ip-address}
//   Username: azureuser
//   Password: (set during deployment)
// ============================================================================

// ============================================================================
// PARAMETERS - Customizable inputs for the module
// ============================================================================

@description('Azure region for compute resources')
param location string

@description('Tags to apply to resources')
param tags object

@description('Name of the App Service Plan')
param appServicePlanName string

@description('Name of the Web App')
param webAppName string

@description('Name of the Windows VM')
param vmName string = 'vm-win-learn'

@description('Admin username for the Windows VM')
param adminUsername string = 'azureuser'

@description('Admin password for the Windows VM')
@secure()
param adminPassword string

@description('Size of the Windows VM')
@allowed([
  'Standard_B1s'
  'Standard_B2s'
  'Standard_B2ms'
  'Standard_D2s_v5'
])
param vmSize string = 'Standard_B1s'

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
// WINDOWS VIRTUAL MACHINE INFRASTRUCTURE
// ============================================================================
// A VM requires several supporting resources:
//   1. VNet + Subnet = Private network the VM lives in
//   2. Network Interface (NIC) = VM's network connection
//   3. Public IP = Internet-accessible IP address
//   4. NSG = Firewall rules controlling traffic
//
// The order of creation matters - dependencies are implicit in Bicep
// based on resource references.

// ----------------------------------------------------------------------------
// Virtual Network - Private network for the VM
// ----------------------------------------------------------------------------
resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: 'vnet-${vmName}'
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'  // 65,536 private IPs
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.1.0.0/24'  // 256 IPs for VMs
        }
      }
    ]
  }
}

// ----------------------------------------------------------------------------
// Public IP - Internet-accessible address for RDP
// ----------------------------------------------------------------------------
// Standard SKU provides better availability and security features
// Static allocation means the IP doesn't change when VM restarts
resource publicIp 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: 'pip-${vmName}'
  location: location
  tags: tags
  sku: {
    name: 'Standard'  // Standard SKU required for zone redundancy
  }
  properties: {
    publicIPAllocationMethod: 'Static'  // IP persists across VM restarts
    dnsSettings: {
      // Creates DNS name like: vm-win-learn-abc123.centralus.cloudapp.azure.com
      domainNameLabel: toLower('${vmName}-${uniqueString(resourceGroup().id)}')
    }
  }
}

// ----------------------------------------------------------------------------
// Network Security Group - Firewall for the VM
// ----------------------------------------------------------------------------
// SECURITY WARNING: RDP from anywhere (*) is for training only!
// In production, restrict to your IP or use Azure Bastion.
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: 'nsg-${vmName}'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowRDP'
        properties: {
          priority: 1000
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// ----------------------------------------------------------------------------
// Network Interface - Connects VM to the network
// ----------------------------------------------------------------------------
// The NIC bridges the VM to the VNet and associates the public IP
resource nic 'Microsoft.Network/networkInterfaces@2023-11-01' = {
  name: 'nic-${vmName}'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

// ----------------------------------------------------------------------------
// Windows Virtual Machine
// ----------------------------------------------------------------------------
// Windows Server 2022 Datacenter - Azure optimized edition
// B2s = 2 vCPUs, 4GB RAM - Good for development and testing
resource windowsVm 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: vmName
  location: location
  tags: union(tags, {
    os: 'windows'
    purpose: 'learning-rdp'
  })
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: take(vmName, 15) // Windows computer name max 15 chars
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        name: 'osdisk-${vmName}'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

// ----------------------------------------------------------------------------
// Auto-Shutdown Schedule - Saves costs during training
// ----------------------------------------------------------------------------
// IMPORTANT: This shuts down the VM at 7 PM UTC daily
// Learners should start the VM manually when needed
// To disable: set status to 'Disabled' or delete this resource
resource autoShutdown 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: 'shutdown-computevm-${vmName}'
  location: location
  tags: tags
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '1900'
    }
    timeZoneId: 'UTC'
    targetResourceId: windowsVm.id
    notificationSettings: {
      status: 'Disabled'
    }
  }
}

// ============================================================================
// APP SERVICE PLAN - PaaS compute platform
// ============================================================================
// App Service Plans define the compute resources for web apps:
//   F1 (Free): 1GB RAM, 60 CPU minutes/day - Great for learning
//   B1 (Basic): 1.75GB RAM, always-on - Good for dev/test
//   S1 (Standard): Auto-scale, slots, backups - Production ready
//   P1v2 (Premium): Better perf, more slots - Enterprise
//
// Multiple web apps can share one App Service Plan

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
// WEB APP - The actual web application
// ============================================================================
// Web Apps are managed app hosting with built-in features:
//   - Automatic patching and maintenance
//   - Deployment slots for blue/green deployments
//   - Built-in authentication (Easy Auth)
//   - Custom domains and SSL certificates
//
// This web app is configured for .NET 8 applications

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

// App settings configure the runtime environment
resource webAppSettings 'Microsoft.Web/sites/config@2023-12-01' = {
  parent: webApp
  name: 'appsettings'
  properties: {
    WEBSITE_RUN_FROM_PACKAGE: '1'       // Run directly from deployment package
    ASPNETCORE_ENVIRONMENT: 'Production' // .NET environment name
  }
}

// ============================================================================
// OUTPUTS - Values returned to the calling template
// ============================================================================
// These outputs provide connection information for the deployed resources

// App Service outputs
output appServicePlanId string = appServicePlan.id
output appServicePlanName string = appServicePlan.name
output webAppName string = webApp.name
output webAppUrl string = 'https://${webApp.properties.defaultHostName}'

// Windows VM outputs - Use these to connect to the VM
output vmName string = windowsVm.name
output vmPublicIp string = publicIp.properties.ipAddress
output vmFqdn string = publicIp.properties.dnsSettings.fqdn
output vmAdminUsername string = adminUsername
output rdpCommand string = 'mstsc /v:${publicIp.properties.ipAddress}'  // Copy-paste RDP command
