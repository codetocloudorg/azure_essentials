# Lesson 06: Compute — Linux & Kubernetes - Copy-Paste Commands

> Deploy Linux VMs and set up MicroK8s

---

## 📋 Setup Variables

Copy and paste this block first to set up your variables:

```bash
# Configuration
LOCATION="centralus"
RESOURCE_GROUP="rg-essentials-linux"
UNIQUE_SUFFIX=$(openssl rand -hex 4)
VM_NAME="vm-linux-${UNIQUE_SUFFIX}"
ADMIN_USERNAME="azureuser"

# Display the VM name (save this!)
echo "VM Name: $VM_NAME"
```

---

## Step 1: Create Resource Group

```bash
# Create the resource group
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --tags "course=azure-essentials" "lesson=06-linux"
```

---

## Step 2: Create Virtual Network

```bash
# Create VNet for the Linux VM
az network vnet create \
    --name "vnet-linux" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --address-prefix "10.2.0.0/16" \
    --subnet-name "snet-vms" \
    --subnet-prefix "10.2.1.0/24"
```

---

## Step 3: Create Network Security Group

```bash
# Create NSG
az network nsg create \
    --name "nsg-linux-vm" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION"
```

```bash
# Allow SSH (port 22)
az network nsg rule create \
    --name "AllowSSH" \
    --nsg-name "nsg-linux-vm" \
    --resource-group "$RESOURCE_GROUP" \
    --priority 100 \
    --direction Inbound \
    --access Allow \
    --protocol Tcp \
    --destination-port-ranges 22
```

```bash
# Allow Kubernetes API (port 16443 for MicroK8s)
az network nsg rule create \
    --name "AllowK8sAPI" \
    --nsg-name "nsg-linux-vm" \
    --resource-group "$RESOURCE_GROUP" \
    --priority 110 \
    --direction Inbound \
    --access Allow \
    --protocol Tcp \
    --destination-port-ranges 16443
```

```bash
# Allow HTTP for web apps
az network nsg rule create \
    --name "AllowHTTP" \
    --nsg-name "nsg-linux-vm" \
    --resource-group "$RESOURCE_GROUP" \
    --priority 120 \
    --direction Inbound \
    --access Allow \
    --protocol Tcp \
    --destination-port-ranges 80
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

## Step 5: Create SSH Key (if needed)

```bash
# Generate SSH key pair (skip if you already have one)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure_vm_key -N ""
```

---

## Step 6: Create Linux VM with Cloud-Init

First, create the cloud-init file:

```bash
# Create cloud-init configuration for MicroK8s
cat << 'EOF' > /tmp/cloud-init.yaml
#cloud-config
package_update: true
package_upgrade: true

packages:
  - snapd
  - curl
  - git

snap:
  commands:
    - snap install microk8s --classic

runcmd:
  - usermod -a -G microk8s azureuser
  - mkdir -p /home/azureuser/.kube
  - chown -R azureuser:azureuser /home/azureuser/.kube
  - microk8s status --wait-ready
  - microk8s enable dns dashboard storage
  - echo "alias kubectl='microk8s kubectl'" >> /home/azureuser/.bashrc
EOF
```

Now create the VM:

```bash
# Create Ubuntu 24.04 VM with MicroK8s
az vm create \
    --name "$VM_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --image "Canonical:ubuntu-24_04-lts:server:latest" \
    --size "Standard_B2ms" \
    --admin-username "$ADMIN_USERNAME" \
    --ssh-key-values ~/.ssh/azure_vm_key.pub \
    --vnet-name "vnet-linux" \
    --subnet "snet-vms" \
    --nsg "nsg-linux-vm" \
    --public-ip-address "pip-${VM_NAME}" \
    --custom-data /tmp/cloud-init.yaml
```

---

## Step 7: Get VM Connection Info

```bash
# Get the public IP address
PUBLIC_IP=$(az vm show \
    --name "$VM_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --show-details \
    --query publicIps \
    -o tsv)

echo "SSH Command: ssh -i ~/.ssh/azure_vm_key ${ADMIN_USERNAME}@${PUBLIC_IP}"
```

---

## Step 8: Connect to VM

```bash
# SSH into the VM
ssh -i ~/.ssh/azure_vm_key ${ADMIN_USERNAME}@${PUBLIC_IP}
```

---

## 📊 Commands to Run INSIDE the VM

Once connected via SSH, run these commands:

### Check MicroK8s Status

```bash
# Check if MicroK8s is ready (run inside VM)
microk8s status
```

### View Kubernetes Nodes

```bash
# List nodes (run inside VM)
microk8s kubectl get nodes
```

### Deploy a Sample App

```bash
# Create a simple nginx deployment (run inside VM)
microk8s kubectl create deployment nginx --image=nginx

# Expose it as a service
microk8s kubectl expose deployment nginx --port=80 --type=NodePort

# Get the service details
microk8s kubectl get services
```

### View All Resources

```bash
# Get all resources (run inside VM)
microk8s kubectl get all
```

---

## 📚 Additional Commands

### View VM Details

```bash
az vm show \
    --name "$VM_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query "{Name:name, Size:hardwareProfile.vmSize, OS:storageProfile.imageReference.offer}" \
    -o table
```

### Start/Stop VM

```bash
# Stop the VM (deallocates - stops billing)
az vm deallocate --name "$VM_NAME" --resource-group "$RESOURCE_GROUP"
```

```bash
# Start the VM
az vm start --name "$VM_NAME" --resource-group "$RESOURCE_GROUP"
```

### Run Command on VM

```bash
# Run a command on the VM remotely
az vm run-command invoke \
    --name "$VM_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --command-id RunShellScript \
    --scripts "microk8s kubectl get nodes"
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

```bash
# Also clean up the temp cloud-init file
rm -f /tmp/cloud-init.yaml
```

---

## 🔗 Quick Reference

| Command | Description |
|---------|-------------|
| `az vm create` | Create a virtual machine |
| `az vm show --show-details` | Show VM with public IP |
| `az vm start` | Start a VM |
| `az vm deallocate` | Stop and deallocate a VM |
| `az vm run-command invoke` | Run command remotely |
| `microk8s status` | Check MicroK8s status |
| `microk8s kubectl` | Run kubectl commands |
