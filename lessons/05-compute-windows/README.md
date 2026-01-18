# Lesson 05: Compute Services - Windows

> **Duration**: 30 minutes | **Day**: 1

## Overview

Azure provides flexible compute options for running Windows workloads. This lesson covers Windows virtual machines, availability options, and Azure App Service for web applications.

## What Gets Deployed

When you deploy this lesson using the deploy script, you get:

| Resource | Description | Purpose |
|----------|-------------|---------|
| **Windows Server 2022 VM** | Standard_B2s (2 vCPUs, 4GB RAM) | Practice RDP connections, Windows administration |
| **Virtual Network** | 10.1.0.0/16 with default subnet | Isolated network for the VM |
| **Public IP Address** | Static allocation with DNS label | RDP access from internet |
| **Network Security Group** | Allow RDP (port 3389) | Secure inbound access |
| **App Service Plan** | F1 (Free tier) | Host web applications |
| **Web App** | .NET runtime | Deploy sample applications |

> ⚠️ **Cost Note**: The VM uses B2s size which uses Azure credits. An auto-shutdown is configured for 7 PM UTC to save costs. Stop/deallocate the VM when not in use.

### Connecting to Your Windows VM

After deployment, the outputs will show your connection information:

```bash
# The deploy script outputs:
WINDOWS_VM_PUBLIC_IP=<your-vm-ip>
WINDOWS_VM_FQDN=<your-vm-fqdn>

# Connect via Remote Desktop
# Windows: mstsc /v:<your-vm-fqdn>
# macOS: Use Microsoft Remote Desktop app
# Linux: Use remmina or xfreerdp
```

**Connection Details**:
- **Username**: `azureuser`
- **Password**: The password you entered during deployment
- **Port**: 3389 (RDP)

## Learning Objectives

By the end of this lesson, you will be able to:

- Choose appropriate VM sizes for different workloads
- Deploy and connect to a Windows virtual machine
- Understand availability sets and zones
- Deploy a web application to Azure App Service
- Compare IaaS (VMs) versus PaaS (App Service) approaches

---

## Key Concepts

### Virtual Machine Sizes

Azure VMs come in different series for different workloads:

| Series | Purpose | Example Sizes |
|--------|---------|---------------|
| **B** | Burstable, cost-effective | B1s, B2s, B4ms |
| **D** | General purpose | D2s_v5, D4s_v5 |
| **E** | Memory optimised | E2s_v5, E4s_v5 |
| **F** | Compute optimised | F2s_v2, F4s_v2 |
| **N** | GPU enabled | NC6, NV6 |

### Availability Options

| Option | Protection Level | SLA |
|--------|-----------------|-----|
| **Single VM (Premium SSD)** | Hardware failure | 99.9% |
| **Availability Set** | Rack-level failure | 99.95% |
| **Availability Zone** | Datacentre failure | 99.99% |

### IaaS vs PaaS Comparison

| Aspect | Virtual Machines (IaaS) | App Service (PaaS) |
|--------|------------------------|---------------------|
| **Control** | Full OS control | Application only |
| **Maintenance** | You patch and update | Microsoft manages |
| **Scaling** | Manual or VMSS | Built-in auto-scale |
| **Cost** | Pay for VM uptime | Pay for plan tier |
| **Best for** | Lift-and-shift, custom software | Modern web apps |

---

## Hands-on Exercises

### Exercise 5.1: Deploy a Windows Virtual Machine

**Objective**: Create a Windows Server VM and connect via RDP.

```bash
# Variables
RESOURCE_GROUP="rg-azure-essentials-dev"
LOCATION="uksouth"
VM_NAME="vm-windows-001"
ADMIN_USER="azureuser"

# Create the VM (you'll be prompted for a password)
az vm create \
  --name $VM_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --image Win2022Datacenter \
  --size Standard_B2s \
  --admin-username $ADMIN_USER \
  --public-ip-sku Standard

# Open RDP port
az vm open-port \
  --name $VM_NAME \
  --resource-group $RESOURCE_GROUP \
  --port 3389

# Get the public IP address
az vm show \
  --name $VM_NAME \
  --resource-group $RESOURCE_GROUP \
  --show-details \
  --query publicIps \
  --output tsv
```

**Connect to the VM**:

1. Open Remote Desktop Connection on your computer
2. Enter the public IP address from the previous command
3. Log in with the username and password you provided
4. Accept the certificate warning

### Exercise 5.2: Explore VM Management

**Objective**: Learn common VM management operations.

```bash
# View VM details
az vm show \
  --name $VM_NAME \
  --resource-group $RESOURCE_GROUP \
  --output table

# Stop the VM (deallocate to stop billing)
az vm deallocate \
  --name $VM_NAME \
  --resource-group $RESOURCE_GROUP

# Start the VM
az vm start \
  --name $VM_NAME \
  --resource-group $RESOURCE_GROUP

# Resize the VM
az vm resize \
  --name $VM_NAME \
  --resource-group $RESOURCE_GROUP \
  --size Standard_B4ms

# List available sizes in your region
az vm list-sizes --location $LOCATION --output table
```

### Exercise 5.3: Deploy to Azure App Service

**Objective**: Deploy a simple web application using App Service.

```bash
# Variables
APP_NAME="app-essentials-$(openssl rand -hex 4)"
PLAN_NAME="asp-azure-essentials"

# Create an App Service Plan (Free tier)
az appservice plan create \
  --name $PLAN_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku F1

# Create a Web App
az webapp create \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --plan $PLAN_NAME \
  --runtime "DOTNET|8.0"

# Get the URL
az webapp show \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --query defaultHostName \
  --output tsv

echo "Your app is at: https://$APP_NAME.azurewebsites.net"
```

### Exercise 5.4: Deploy Sample Code to App Service

**Objective**: Deploy a sample application from GitHub.

```bash
# Deploy a sample .NET app from GitHub
az webapp deployment source config \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --repo-url "https://github.com/Azure-Samples/dotnet-core-sample" \
  --branch master \
  --manual-integration

# Check deployment status
az webapp deployment source show \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP

# Open the app in your browser
az webapp browse \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP
```

---

## Clean Up Exercise Resources

To avoid charges, clean up the VM when done:

```bash
# Delete the VM and its resources
az vm delete \
  --name $VM_NAME \
  --resource-group $RESOURCE_GROUP \
  --yes

# Also delete associated resources
az network nic delete --name ${VM_NAME}VMNic --resource-group $RESOURCE_GROUP
az network public-ip delete --name ${VM_NAME}PublicIP --resource-group $RESOURCE_GROUP
az disk delete --name ${VM_NAME}_OsDisk_1 --resource-group $RESOURCE_GROUP --yes
```

---

## Key Commands Reference

```bash
# Virtual machines
az vm create --name <n> --resource-group <rg> --image <img> --size <s>
az vm start --name <n> --resource-group <rg>
az vm stop --name <n> --resource-group <rg>
az vm deallocate --name <n> --resource-group <rg>
az vm delete --name <n> --resource-group <rg>
az vm list-sizes --location <loc>

# App Service
az appservice plan create --name <n> --sku <s>
az webapp create --name <n> --plan <p> --runtime <r>
az webapp deployment source config --repo-url <url>
az webapp browse --name <n>
```

---

## Summary

In this lesson, you learned:

- ✅ Azure VM sizing and series options
- ✅ Deploying and connecting to Windows VMs
- ✅ VM lifecycle management (start, stop, resize)
- ✅ Azure App Service for PaaS web hosting
- ✅ Deploying applications to App Service

---

## Next Steps

Continue to [Lesson 06: Compute Services - Linux and Kubernetes](../06-compute-linux-kubernetes/README.md) to work with Linux workloads.

---

## Additional Resources

- [Virtual Machines Documentation](https://learn.microsoft.com/azure/virtual-machines/)
- [App Service Documentation](https://learn.microsoft.com/azure/app-service/)
- [VM Sizing Guide](https://learn.microsoft.com/azure/virtual-machines/sizes)
