# Lesson 04: Networking

> **Time:** 30 minutes | **Difficulty:** Medium | **Cost:** ~$0 (components are mostly free)

## 🎯 What You'll Build

By the end of this lesson, you'll have:
- Created a Virtual Network (VNet)
- Configured subnets
- Set up a Network Security Group (NSG)
- Understood how Azure networking works

---

## 🔌 Azure Networking Basics

### The Big Picture

Think of Azure networking like setting up your own private house:

| Azure Term | Real World Analogy |
|------------|-------------------|
| **Virtual Network (VNet)** | Your property/lot |
| **Subnet** | Rooms in your house |
| **NSG (Network Security Group)** | Locks on doors |
| **IP Address** | Your home address |
| **Firewall** | Security guard at the gate |

### Default Behavior

> ⚠️ **Important:** By default, VMs in Azure have **no internet access inbound** unless you explicitly open ports.

This is different from your home network where everything can connect to the internet.

---

## 🏗️ Virtual Networks (VNets)

A VNet is your private network in Azure. It's isolated from other customers.

### Create a VNet

```bash
# Variables
RG_NAME="rg-network-lesson"
LOCATION="centralus"
VNET_NAME="vnet-main"

# Create resource group
az group create --name $RG_NAME --location $LOCATION

# Create VNet with address space
az network vnet create \
  --resource-group $RG_NAME \
  --name $VNET_NAME \
  --address-prefix 10.0.0.0/16 \
  --location $LOCATION
```

### Understanding Address Spaces

| Notation | What It Means | # of IPs |
|----------|---------------|----------|
| `10.0.0.0/16` | IPs from 10.0.0.0 to 10.0.255.255 | ~65,000 |
| `10.0.1.0/24` | IPs from 10.0.1.0 to 10.0.1.255 | ~250 |
| `10.0.1.0/28` | IPs from 10.0.1.0 to 10.0.1.15 | 16 |

**Rule of thumb:** Start with `/16` for your VNet, `/24` for each subnet.

---

## 📦 Subnets

Subnets divide your VNet into smaller sections. Like rooms in a house.

### Why Subnets?

| Reason | Example |
|--------|---------|
| **Organize** | Web servers in one subnet, databases in another |
| **Security** | Apply different rules to different subnets |
| **Services** | Some Azure services need their own dedicated subnet |

### Create Subnets

```bash
# Web tier subnet (for web servers)
az network vnet subnet create \
  --resource-group $RG_NAME \
  --vnet-name $VNET_NAME \
  --name subnet-web \
  --address-prefix 10.0.1.0/24

# Database tier subnet
az network vnet subnet create \
  --resource-group $RG_NAME \
  --vnet-name $VNET_NAME \
  --name subnet-database \
  --address-prefix 10.0.2.0/24

# List subnets
az network vnet subnet list \
  --resource-group $RG_NAME \
  --vnet-name $VNET_NAME \
  --output table
```

---

## 🔒 Network Security Groups (NSGs)

NSGs are like firewalls. They control what traffic can enter or leave.

### Create an NSG

```bash
NSG_NAME="nsg-web"

az network nsg create \
  --resource-group $RG_NAME \
  --name $NSG_NAME \
  --location $LOCATION
```

### Add Rules

```bash
# Allow HTTP (port 80) from internet
az network nsg rule create \
  --resource-group $RG_NAME \
  --nsg-name $NSG_NAME \
  --name AllowHTTP \
  --priority 100 \
  --source-address-prefixes Internet \
  --destination-port-ranges 80 \
  --access Allow \
  --protocol Tcp \
  --direction Inbound

# Allow HTTPS (port 443) from internet
az network nsg rule create \
  --resource-group $RG_NAME \
  --nsg-name $NSG_NAME \
  --name AllowHTTPS \
  --priority 110 \
  --source-address-prefixes Internet \
  --destination-port-ranges 443 \
  --access Allow \
  --protocol Tcp \
  --direction Inbound
```

### Rule Priority

Lower number = checked first.

| Priority | Rule | Action |
|----------|------|--------|
| 100 | AllowHTTP | Allow |
| 110 | AllowHTTPS | Allow |
| 65000 | DenyAllInbound (built-in) | Deny |

If traffic matches rule 100, it's allowed. If nothing matches, it hits the default deny.

### Apply NSG to Subnet

```bash
az network vnet subnet update \
  --resource-group $RG_NAME \
  --vnet-name $VNET_NAME \
  --name subnet-web \
  --network-security-group $NSG_NAME
```

---

## 🌐 Public IP Addresses

To access a VM from the internet, it needs a public IP.

### Create a Public IP

```bash
az network public-ip create \
  --resource-group $RG_NAME \
  --name pip-webserver \
  --allocation-method Static \
  --sku Standard
```

### Static vs Dynamic

| Type | Behavior | Best For |
|------|----------|----------|
| **Static** | Same IP forever | Production servers, DNS |
| **Dynamic** | Changes when VM restarts | Development/testing |

---

## 🔍 View Your Network

### List All Resources

```bash
# See VNet details
az network vnet show \
  --resource-group $RG_NAME \
  --name $VNET_NAME \
  --output table

# See NSG rules
az network nsg rule list \
  --resource-group $RG_NAME \
  --nsg-name $NSG_NAME \
  --output table
```

### In the Portal

1. Go to your resource group
2. Click on the VNet to see a visual diagram
3. Click on the NSG to see inbound/outbound rules

---

## 📊 Common Subnet Patterns

### Three-Tier Architecture

```
VNet: 10.0.0.0/16
├── subnet-web: 10.0.1.0/24      ← Public-facing
├── subnet-app: 10.0.2.0/24      ← Application logic
└── subnet-db:  10.0.3.0/24      ← Database (most protected)
```

### With Bastion Host

```
VNet: 10.0.0.0/16
├── AzureBastionSubnet: 10.0.0.0/26  ← For secure remote access
├── subnet-web: 10.0.1.0/24
└── subnet-db:  10.0.2.0/24
```

---

## 🧹 Clean Up

```bash
az group delete --name $RG_NAME --yes
```

---

## ⚠️ Common Mistakes

| Mistake | Fix |
|---------|-----|
| VM has no internet access | Check NSG rules, is the port open? |
| Can't SSH/RDP to VM | Need NSG rule for port 22/3389 + public IP |
| Subnet too small | Use /24 (250 IPs) not /28 (16 IPs) |
| NSG on wrong resource | Apply to subnet OR NIC, not both |

---

## ✅ What You Learned

- 🔌 What a VNet is and why you need one
- 📦 How to create and divide subnets
- 🔒 How NSGs control network traffic
- 🌐 How public IPs enable internet access

---

## ➡️ Next Steps

Let's put a VM in this network!

👉 **[Lesson 05: Windows VM](Lesson-05-Compute-Windows)**

---

*Questions? Join our [Discord](https://discord.gg/vwfwq2EpXJ) community!*
