# Lesson 05: Compute — Windows - Copy-Paste Commands

> Deploy Windows VMs and Azure App Service

---

## 📋 Setup Variables

Copy and paste this block first to set up your variables:

```bash
# Configuration
LOCATION="centralus"
RESOURCE_GROUP="rg-essentials-windows"
UNIQUE_SUFFIX=$(openssl rand -hex 4)
VM_NAME="vm-win-${UNIQUE_SUFFIX}"
APP_NAME="app-essentials-${UNIQUE_SUFFIX}"
ADMIN_USERNAME="azureuser"

# Display names (save these!)
echo "VM Name: $VM_NAME"
echo "App Name: $APP_NAME"
```

---

## Step 1: Create Resource Group

```bash
# Create the resource group
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --tags "course=azure-essentials" "lesson=05-windows"
```

---

## Step 2: Create Virtual Network

```bash
# Create VNet for the VM
az network vnet create \
    --name "vnet-windows" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --address-prefix "10.1.0.0/16" \
    --subnet-name "snet-vms" \
    --subnet-prefix "10.1.1.0/24"
```

---

## Step 3: Create Network Security Group

```bash
# Create NSG
az network nsg create \
    --name "nsg-windows-vm" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION"
```

```bash
# Allow RDP (port 3389)
az network nsg rule create \
    --name "AllowRDP" \
    --nsg-name "nsg-windows-vm" \
    --resource-group "$RESOURCE_GROUP" \
    --priority 100 \
    --direction Inbound \
    --access Allow \
    --protocol Tcp \
    --destination-port-ranges 3389
```

---

## Step 4: Create Public IP

```bash
# Create a public IP for the VM
az network public-ip create \
    --name "pip-${VM_NAME}" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku Standard \
    --allocation-method Static
```

---

## Step 5: Create Windows VM

> ⚠️ **Password Requirements**: 12+ characters, uppercase, lowercase, number, special character

```bash
# Set your admin password (change this!)
ADMIN_PASSWORD="YourSecureP@ssw0rd123!"

# Create the Windows Server 2022 VM
az vm create \
    --name "$VM_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --image "MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition:latest" \
    --size "Standard_B2s" \
    --admin-username "$ADMIN_USERNAME" \
    --admin-password "$ADMIN_PASSWORD" \
    --vnet-name "vnet-windows" \
    --subnet "snet-vms" \
    --nsg "nsg-windows-vm" \
    --public-ip-address "pip-${VM_NAME}"
```

---

## Step 6: Get VM Connection Info

```bash
# Get the public IP address
az vm show \
    --name "$VM_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --show-details \
    --query publicIps \
    -o tsv
```

```bash
# Show VM details
az vm show \
    --name "$VM_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query "{Name:name, Size:hardwareProfile.vmSize, OS:storageProfile.osDisk.osType}" \
    -o table
```

---

## Part 2: Azure App Service

---

## Step 7: Create App Service Plan

```bash
# Create an App Service Plan (F1 is free tier)
az appservice plan create \
    --name "plan-${APP_NAME}" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku F1 \
    --is-linux false
```

---

## Step 8: Create Web App

```bash
# Create a .NET web app
az webapp create \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --plan "plan-${APP_NAME}" \
    --runtime "dotnet:8"
```

---

## Step 9: Configure Web App Settings

```bash
# Enable logging
az webapp log config \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --web-server-logging filesystem
```

```bash
# Add an application setting
az webapp config appsettings set \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --settings "ENVIRONMENT=Development" "COURSE=AzureEssentials"
```

---

## Step 10: Get Web App URL

```bash
# Get the default hostname
az webapp show \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query defaultHostName \
    -o tsv
```

---

## 📊 View Resources

### List All VMs

```bash
az vm list \
    --resource-group "$RESOURCE_GROUP" \
    --query "[].{Name:name, Size:hardwareProfile.vmSize, State:provisioningState}" \
    -o table
```

### List All Web Apps

```bash
az webapp list \
    --resource-group "$RESOURCE_GROUP" \
    --query "[].{Name:name, State:state, URL:defaultHostName}" \
    -o table
```

---

## 📚 Additional Commands

### Start/Stop/Restart VM

```bash
# Stop the VM (deallocates - stops billing for compute)
az vm deallocate --name "$VM_NAME" --resource-group "$RESOURCE_GROUP"
```

```bash
# Start the VM
az vm start --name "$VM_NAME" --resource-group "$RESOURCE_GROUP"
```

```bash
# Restart the VM
az vm restart --name "$VM_NAME" --resource-group "$RESOURCE_GROUP"
```

### Start/Stop Web App

```bash
# Stop the web app
az webapp stop --name "$APP_NAME" --resource-group "$RESOURCE_GROUP"
```

```bash
# Start the web app
az webapp start --name "$APP_NAME" --resource-group "$RESOURCE_GROUP"
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
| `az vm create` | Create a virtual machine |
| `az vm show` | Show VM details |
| `az vm start` | Start a VM |
| `az vm deallocate` | Stop and deallocate a VM |
| `az appservice plan create` | Create App Service Plan |
| `az webapp create` | Create a Web App |
| `az webapp config appsettings set` | Configure app settings |
