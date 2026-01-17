# Lesson 04: Networking Services

> **Duration**: 35 minutes | **Day**: 1

## Overview

Azure networking provides the foundation for connecting your cloud resources securely. This lesson covers virtual networks, subnets, network security groups, and load balancers.

## Learning Objectives

By the end of this lesson, you will be able to:

- Design and create virtual networks with proper address spacing
- Configure subnets for different workload tiers
- Create and apply network security group rules
- Understand load balancer concepts
- Connect resources using private endpoints

---

## Key Concepts

### Virtual Network (VNet) Architecture

A virtual network is an isolated network in Azure where you deploy resources:

```
Virtual Network (10.0.0.0/16)
├── Subnet: Web Tier (10.0.1.0/24)
│   └── Network Security Group: Allow HTTP/HTTPS
├── Subnet: App Tier (10.0.2.0/24)
│   └── Network Security Group: Allow from Web Tier
└── Subnet: Data Tier (10.0.3.0/24)
    └── Network Security Group: Allow from App Tier
```

### IP Address Planning

| CIDR Block | Available IPs | Use Case |
|------------|--------------|----------|
| /16 | 65,536 | Large VNet |
| /24 | 256 | Typical subnet |
| /27 | 32 | Small subnet |
| /28 | 16 | Very small subnet |

> **Note**: Azure reserves 5 IP addresses in each subnet for internal use.

### Network Security Groups (NSGs)

NSGs filter network traffic using rules:

| Property | Description |
|----------|-------------|
| **Priority** | Lower numbers process first (100-4096) |
| **Direction** | Inbound or Outbound |
| **Action** | Allow or Deny |
| **Protocol** | TCP, UDP, ICMP, or Any |
| **Source/Destination** | IP, CIDR, service tag, or ASG |

---

## Hands-on Exercises

### Exercise 4.1: Create a Virtual Network

**Objective**: Create a VNet with three subnets for a typical three-tier application.

```bash
# Variables
RESOURCE_GROUP="rg-azure-essentials-dev"
LOCATION="uksouth"
VNET_NAME="vnet-azure-essentials"

# Create the virtual network
az network vnet create \
  --name $VNET_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --address-prefix 10.0.0.0/16

# Create subnets for each tier
az network vnet subnet create \
  --name snet-web \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --address-prefix 10.0.1.0/24

az network vnet subnet create \
  --name snet-app \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --address-prefix 10.0.2.0/24

az network vnet subnet create \
  --name snet-data \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --address-prefix 10.0.3.0/24

# View the VNet and subnets
az network vnet show \
  --name $VNET_NAME \
  --resource-group $RESOURCE_GROUP \
  --output table

az network vnet subnet list \
  --vnet-name $VNET_NAME \
  --resource-group $RESOURCE_GROUP \
  --output table
```

### Exercise 4.2: Create Network Security Groups

**Objective**: Create NSGs to control traffic between tiers.

```bash
# Create NSG for web tier
az network nsg create \
  --name nsg-web \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION

# Allow HTTP traffic
az network nsg rule create \
  --nsg-name nsg-web \
  --resource-group $RESOURCE_GROUP \
  --name AllowHTTP \
  --priority 100 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 80

# Allow HTTPS traffic
az network nsg rule create \
  --nsg-name nsg-web \
  --resource-group $RESOURCE_GROUP \
  --name AllowHTTPS \
  --priority 110 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 443

# View NSG rules
az network nsg rule list \
  --nsg-name nsg-web \
  --resource-group $RESOURCE_GROUP \
  --output table
```

### Exercise 4.3: Associate NSG with Subnet

**Objective**: Apply security rules to the web subnet.

```bash
# Associate NSG with web subnet
az network vnet subnet update \
  --name snet-web \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --network-security-group nsg-web

# Verify the association
az network vnet subnet show \
  --name snet-web \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --query networkSecurityGroup.id \
  --output tsv
```

### Exercise 4.4: Create an NSG for App Tier

**Objective**: Create an NSG that only allows traffic from the web tier.

```bash
# Create NSG for app tier
az network nsg create \
  --name nsg-app \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION

# Allow traffic only from web subnet
az network nsg rule create \
  --nsg-name nsg-app \
  --resource-group $RESOURCE_GROUP \
  --name AllowFromWebTier \
  --priority 100 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes 10.0.1.0/24 \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 8080

# Deny all other inbound traffic
az network nsg rule create \
  --nsg-name nsg-app \
  --resource-group $RESOURCE_GROUP \
  --name DenyAllInbound \
  --priority 4000 \
  --direction Inbound \
  --access Deny \
  --protocol '*' \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges '*'

# Associate with app subnet
az network vnet subnet update \
  --name snet-app \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --network-security-group nsg-app
```

---

## Network Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Virtual Network                          │
│                    10.0.0.0/16                              │
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   Web Subnet    │  │   App Subnet    │  │ Data Subnet │ │
│  │   10.0.1.0/24   │──│   10.0.2.0/24   │──│ 10.0.3.0/24 │ │
│  │                 │  │                 │  │             │ │
│  │  NSG: Allow     │  │  NSG: Allow     │  │ NSG: Allow  │ │
│  │  HTTP/HTTPS     │  │  from Web only  │  │ from App    │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
│           ▲                                                 │
│           │                                                 │
└───────────┼─────────────────────────────────────────────────┘
            │
      ┌─────┴─────┐
      │  Internet │
      └───────────┘
```

---

## Key Commands Reference

```bash
# Virtual networks
az network vnet create --name <n> --resource-group <rg> --address-prefix <cidr>
az network vnet list --resource-group <rg> --output table
az network vnet show --name <n> --resource-group <rg>

# Subnets
az network vnet subnet create --name <n> --vnet-name <v> --address-prefix <cidr>
az network vnet subnet list --vnet-name <v> --resource-group <rg>

# Network security groups
az network nsg create --name <n> --resource-group <rg>
az network nsg rule create --nsg-name <n> --name <rule> --priority <p>
az network nsg rule list --nsg-name <n> --resource-group <rg>
```

---

## Summary

In this lesson, you learned:

- ✅ Virtual network concepts and address planning
- ✅ Creating VNets and subnets for multi-tier applications
- ✅ Network security groups and rule configuration
- ✅ Associating NSGs with subnets
- ✅ Designing secure network architecture

---

## Next Steps

Continue to [Lesson 05: Compute Services - Windows](../05-compute-windows/README.md) to deploy your first virtual machine.

---

## Additional Resources

- [Virtual Network Documentation](https://learn.microsoft.com/azure/virtual-network/)
- [NSG Best Practices](https://learn.microsoft.com/azure/virtual-network/network-security-groups-overview)
- [Azure Network Architecture](https://learn.microsoft.com/azure/architecture/guide/networking/networking-start-here)
