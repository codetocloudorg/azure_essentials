# Lesson 04: Networking Services - Copy-Paste Commands

---

## 📋 Setup Variables

Copy and paste this block first to set up your variables:

```bash
# Configuration
LOCATION="centralus"
RESOURCE_GROUP="rg-essentials-networking"
VNET_NAME="vnet-essentials"
NSG_NAME="nsg-essentials-web"
```

---

## Step 1: Create Resource Group

```bash
# Create the resource group
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --tags "course=azure-essentials" "lesson=04-networking"
```

---

## Step 2: Create Virtual Network with Initial Subnet

```bash
# Create VNet with address space 10.0.0.0/16 and first subnet
az network vnet create \
    --name "$VNET_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --address-prefix "10.0.0.0/16" \
    --subnet-name "snet-web" \
    --subnet-prefix "10.0.1.0/24"
```

---

## Step 3: Create Additional Subnets

### Application Tier Subnet

```bash
# Create application tier subnet
az network vnet subnet create \
    --name "snet-app" \
    --vnet-name "$VNET_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --address-prefixes "10.0.2.0/24"
```

### Data Tier Subnet

```bash
# Create data tier subnet
az network vnet subnet create \
    --name "snet-data" \
    --vnet-name "$VNET_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --address-prefixes "10.0.3.0/24"
```

### Azure Bastion Subnet

```bash
# Create Azure Bastion subnet (must use this exact name)
az network vnet subnet create \
    --name "AzureBastionSubnet" \
    --vnet-name "$VNET_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --address-prefixes "10.0.255.0/26"
```

---

## Step 4: Create Network Security Group

```bash
# Create the NSG
az network nsg create \
    --name "$NSG_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION"
```

---

## Step 5: Add NSG Rules

### Allow HTTP (Port 80)

```bash
# Allow inbound HTTP traffic
az network nsg rule create \
    --name "AllowHTTP" \
    --nsg-name "$NSG_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --priority 100 \
    --direction Inbound \
    --access Allow \
    --protocol Tcp \
    --source-address-prefixes "*" \
    --source-port-ranges "*" \
    --destination-address-prefixes "*" \
    --destination-port-ranges 80
```

### Allow HTTPS (Port 443)

```bash
# Allow inbound HTTPS traffic
az network nsg rule create \
    --name "AllowHTTPS" \
    --nsg-name "$NSG_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --priority 110 \
    --direction Inbound \
    --access Allow \
    --protocol Tcp \
    --source-address-prefixes "*" \
    --source-port-ranges "*" \
    --destination-address-prefixes "*" \
    --destination-port-ranges 443
```

### Deny All Other Inbound

```bash
# Explicitly deny all other inbound traffic
az network nsg rule create \
    --name "DenyAllInbound" \
    --nsg-name "$NSG_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --priority 4096 \
    --direction Inbound \
    --access Deny \
    --protocol "*" \
    --source-address-prefixes "*" \
    --source-port-ranges "*" \
    --destination-address-prefixes "*" \
    --destination-port-ranges "*"
```

---

## Step 6: Associate NSG with Subnet

```bash
# Attach the NSG to the web subnet
az network vnet subnet update \
    --name "snet-web" \
    --vnet-name "$VNET_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --network-security-group "$NSG_NAME"
```

---

## 📊 View Network Configuration

### Show Virtual Network Details

```bash
# View VNet with all subnets
az network vnet show \
    --name "$VNET_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query "{Name:name, AddressSpace:addressSpace.addressPrefixes[0], Subnets:subnets[].{Name:name, Prefix:addressPrefix}}" \
    -o json
```

### List All Subnets

```bash
# List subnets in the VNet
az network vnet subnet list \
    --vnet-name "$VNET_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query "[].{Name:name, AddressPrefix:addressPrefix, NSG:networkSecurityGroup.id}" \
    -o table
```

### Show NSG Rules

```bash
# List NSG security rules
az network nsg rule list \
    --nsg-name "$NSG_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query "[].{Name:name, Priority:priority, Direction:direction, Access:access, Port:destinationPortRange}" \
    -o table
```

---

## 📚 Additional Commands

### Create a Public IP Address

```bash
# Create a static public IP
az network public-ip create \
    --name "pip-essentials" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku Standard \
    --allocation-method Static
```

### Show Effective Security Rules

```bash
# View effective NSG rules for a specific NIC (requires a NIC to exist)
# az network nic list-effective-nsg --name <nic-name> --resource-group $RESOURCE_GROUP
```

---

## 🧹 Cleanup

```bash
# Delete the entire resource group
az group delete \
    --name "$RESOURCE_GROUP" \
    --yes \
    --no-wait

echo "Cleanup initiated - resources deleting in background"
```

---

## 🔗 Quick Reference

| Command | Description |
|---------|-------------|
| `az network vnet create` | Create virtual network |
| `az network vnet subnet create` | Add subnet to VNet |
| `az network vnet subnet list` | List all subnets |
| `az network nsg create` | Create network security group |
| `az network nsg rule create` | Add rule to NSG |
| `az network vnet subnet update` | Update subnet (e.g., attach NSG) |
| `az network public-ip create` | Create public IP address |

---

## 🏗️ Network Architecture

```
VNet: vnet-essentials (10.0.0.0/16)
├── snet-web  (10.0.1.0/24)   ← NSG attached
├── snet-app  (10.0.2.0/24)
├── snet-data (10.0.3.0/24)
└── AzureBastionSubnet (10.0.255.0/26)
```
