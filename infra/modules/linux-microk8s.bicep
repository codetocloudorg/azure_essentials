// Azure Linux VM with MicroK8s Module
// Code to Cloud - Azure Essentials
// Lesson 06: Compute - Linux and Kubernetes Intro

@description('Azure region for resources')
param location string

@description('Tags to apply to resources')
param tags object

@description('Name prefix for resources')
param namePrefix string

@description('Admin username for the VM')
param adminUsername string = 'azureuser'

@description('SSH public key for authentication')
@secure()
param sshPublicKey string

@description('VM size - B2s is good balance of cost/performance for learning')
@allowed([
  'Standard_B1s'
  'Standard_B2s'
  'Standard_B2ms'
])
param vmSize string = 'Standard_B2s'

// ============================================================================
// VARIABLES
// ============================================================================

var vmName = '${namePrefix}-microk8s-vm'
var nicName = '${namePrefix}-microk8s-nic'
var publicIpName = '${namePrefix}-microk8s-pip'
var nsgName = '${namePrefix}-microk8s-nsg'
var vnetName = '${namePrefix}-microk8s-vnet'
var subnetName = 'default'

// Cloud-init script to install MicroK8s
var cloudInitScript = '''
#cloud-config
package_update: true
package_upgrade: true

packages:
  - snapd
  - curl
  - wget
  - git
  - jq

runcmd:
  # Install MicroK8s
  - snap install microk8s --classic --channel=1.28/stable

  # Add azureuser to microk8s group
  - usermod -a -G microk8s azureuser
  - chown -R azureuser:azureuser /home/azureuser/.kube || mkdir -p /home/azureuser/.kube && chown -R azureuser:azureuser /home/azureuser/.kube

  # Wait for MicroK8s to be ready
  - microk8s status --wait-ready

  # Enable essential addons
  - microk8s enable dns
  - microk8s enable dashboard
  - microk8s enable storage
  - microk8s enable registry

  # Create kubectl alias for convenience
  - echo "alias kubectl='microk8s kubectl'" >> /home/azureuser/.bashrc
  - echo "alias k='microk8s kubectl'" >> /home/azureuser/.bashrc

  # Create a welcome message
  - |
    cat > /etc/motd << 'EOF'

    ██████  ██████  ██████  ███████     ████████  ██████       ██████ ██       ██████  ██    ██ ██████
    ██      ██    ██ ██   ██ ██             ██    ██    ██     ██      ██      ██    ██ ██    ██ ██   ██
    ██      ██    ██ ██   ██ █████          ██    ██    ██     ██      ██      ██    ██ ██    ██ ██   ██
    ██      ██    ██ ██   ██ ██             ██    ██    ██     ██      ██      ██    ██ ██    ██ ██   ██
     ██████  ██████  ██████  ███████        ██     ██████       ██████ ███████  ██████   ██████  ██████

    ═══════════════════════════════════════════════════════════════════════════════════════════════════
      Azure Essentials - Lesson 06: Linux & Kubernetes
      MicroK8s is installed and ready!
    ═══════════════════════════════════════════════════════════════════════════════════════════════════

    Quick Commands:
      microk8s status          - Check MicroK8s status
      microk8s kubectl get all - List all resources
      kubectl get nodes        - List cluster nodes (alias configured)
      k get pods -A            - List all pods (short alias)

    Dashboard:
      microk8s dashboard-proxy

    EOF

final_message: "MicroK8s installation complete! Ready for Kubernetes learning."
'''

// ============================================================================
// NETWORK SECURITY GROUP
// ============================================================================

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowSSH'
        properties: {
          priority: 1000
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowKubernetesDashboard'
        properties: {
          priority: 1010
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '10443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// ============================================================================
// VIRTUAL NETWORK
// ============================================================================

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.100.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.100.1.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

// ============================================================================
// PUBLIC IP
// ============================================================================

resource publicIp 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: publicIpName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: toLower('${namePrefix}-microk8s')
    }
  }
}

// ============================================================================
// NETWORK INTERFACE
// ============================================================================

resource nic 'Microsoft.Network/networkInterfaces@2023-11-01' = {
  name: nicName
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
  }
}

// ============================================================================
// VIRTUAL MACHINE
// ============================================================================

resource vm 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: vmName
  location: location
  tags: union(tags, {
    lesson: '06-linux-kubernetes'
    purpose: 'microk8s-learning'
  })
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: 'microk8s'
      adminUsername: adminUsername
      customData: base64(cloudInitScript)
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: sshPublicKey
            }
          ]
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}-osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        diskSizeGB: 30
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

output vmName string = vm.name
output vmId string = vm.id
output publicIpAddress string = publicIp.properties.ipAddress
output fqdn string = publicIp.properties.dnsSettings.fqdn
output sshCommand string = 'ssh ${adminUsername}@${publicIp.properties.dnsSettings.fqdn}'
output adminUsername string = adminUsername
