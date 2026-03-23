# Lesson 06: Compute Services - Linux and Kubernetes

> **Duration**: 25 minutes | **Day**: 1

## Overview

Azure supports a wide range of Linux distributions and Kubernetes workloads. This lesson introduces Linux VMs and provides hands-on experience with MicroK8s for container orchestration.

## What Gets Deployed

When you deploy this lesson using the deploy script, you get:

| Resource                   | Description                           | Purpose                            |
| -------------------------- | ------------------------------------- | ---------------------------------- |
| **Ubuntu 22.04 LTS VM**    | Standard_B2s (2 vCPU, 4GB RAM)        | Practice SSH, Linux administration |
| **MicroK8s**               | Pre-installed via cloud-init          | Learn Kubernetes basics            |
| **Virtual Network**        | 10.0.0.0/16 with default subnet       | Isolated network for the VM        |
| **Public IP Address**      | Static allocation with DNS label      | SSH access from internet           |
| **Network Security Group** | Allow SSH (22), K8s Dashboard (10443) | Secure inbound access              |

> ⚠️ **Cost Note**: The VM uses B2s size (~$30/month if running 24/7). Stop/deallocate the VM when not in use.

> 💡 **Budget Tight?** You can override to B1s (1GB, ~$8/month) but MicroK8s addons may struggle. B2s is recommended for this lesson.

### Connecting to Your Linux VM

After deployment, connect via SSH:

```bash
# Using the deployment script's generated key
ssh -i ~/.ssh/id_ed25519_azure azureuser@<your-vm-ip>

# When prompted for passphrase, enter: azure
```

**Connection Details**:

- **Username**: `azureuser`
- **SSH Key**: `~/.ssh/id_ed25519_azure`
- **Passphrase**: `azure`
- **Port**: 22 (SSH)

> ✅ **SSH Access Ready**: The deployment automatically creates an NSG rule allowing SSH (port 22) from any IP. You can connect immediately after deployment completes. In production, restrict this to specific IP addresses or use Azure Bastion.

## Learning Objectives

By the end of this lesson, you will be able to:

- Deploy and connect to Linux virtual machines
- Use SSH for secure remote access
- Install and configure MicroK8s on a Linux VM
- Deploy containerised applications to Kubernetes
- Scale workloads using kubectl

---

## Key Concepts

### Supported Linux Distributions

Azure supports many Linux distributions:

| Distribution                 | Use Case                     |
| ---------------------------- | ---------------------------- |
| **Ubuntu**                   | General purpose, development |
| **Red Hat Enterprise Linux** | Enterprise workloads         |
| **Debian**                   | Stability, servers           |
| **CentOS**                   | RHEL compatibility           |
| **SUSE**                     | SAP workloads                |

### Kubernetes Fundamentals

Key Kubernetes concepts:

| Concept              | Description                                       |
| -------------------- | ------------------------------------------------- |
| **Pod**              | Smallest deployable unit (one or more containers) |
| **Deployment**       | Manages pod replicas and updates                  |
| **Service**          | Exposes pods to network traffic                   |
| **Namespace**        | Logical isolation within a cluster                |
| **ConfigMap/Secret** | Configuration and sensitive data                  |

### Why MicroK8s?

MicroK8s is a lightweight Kubernetes distribution:

- ✅ Single-node installation
- ✅ Low resource requirements
- ✅ Quick setup (minutes, not hours)
- ✅ Great for learning and development

---

## Hands-on Exercises

### Exercise 6.1: Deploy a Linux Virtual Machine

**Objective**: Create an Ubuntu VM and connect via SSH.

```bash
# Variables
RESOURCE_GROUP="rg-azure-essentials-dev"
LOCATION="centralus"
VM_NAME="vm-linux-001"
ADMIN_USER="azureuser"

# Create the VM with SSH key authentication
az vm create \
  --name $VM_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --image Ubuntu2204 \
  --size Standard_D2s_v5 \
  --admin-username $ADMIN_USER \
  --generate-ssh-keys \
  --public-ip-sku Standard

# Get the public IP address
VM_IP=$(az vm show \
  --name $VM_NAME \
  --resource-group $RESOURCE_GROUP \
  --show-details \
  --query publicIps \
  --output tsv)

echo "VM IP Address: $VM_IP"

# Connect via SSH
ssh $ADMIN_USER@$VM_IP
```

### Exercise 6.2: Install MicroK8s

**Objective**: Install MicroK8s on the Linux VM.

Run these commands after connecting via SSH:

```bash
# Update package lists
sudo apt update

# Install MicroK8s
sudo snap install microk8s --classic

# Add current user to microk8s group
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube

# Apply group changes (or log out and back in)
newgrp microk8s

# Wait for MicroK8s to be ready
microk8s status --wait-ready

# Enable essential addons
microk8s enable dns
microk8s enable dashboard
microk8s enable storage

# Create an alias for kubectl
echo "alias kubectl='microk8s kubectl'" >> ~/.bashrc
source ~/.bashrc

# Verify installation
kubectl get nodes
```

### Exercise 6.3: Deploy Your First Application

**Objective**: Deploy and scale a containerised application.

```bash
# Create a deployment
kubectl create deployment nginx --image=nginx

# Check the deployment status
kubectl get deployments
kubectl get pods

# Expose the deployment as a service
kubectl expose deployment nginx --port=80 --type=NodePort

# Get the service details
kubectl get services

# Scale the deployment
kubectl scale deployment nginx --replicas=3

# Watch the pods scale
kubectl get pods -w
```

### Exercise 6.3b: Expose Your App to the Internet

**Objective**: Access your Kubernetes app from a web browser.

NodePort services are only accessible on the VM's private network by default. To access nginx from your browser, you need to:
1. Find out which port Kubernetes assigned (the NodePort)
2. Open that port in Azure's Network Security Group (NSG)
3. Browse to `http://<VM-IP>:<NodePort>`

---

#### Step 1: Get the NodePort (on the VM via SSH)

Run this command while connected to your VM:

```bash
# Get the assigned NodePort (usually 30000-32767)
kubectl get svc nginx
```

Look for the port number after `80:` in the output. For example:
```
NAME    TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
nginx   NodePort   10.152.183.42   <none>        80:31302/TCP   2m
```
In this example, the **NodePort is 31302**. Write this down!

Test it works locally first:
```bash
curl http://localhost:31302   # Replace 31302 with your NodePort
```

You should see HTML output starting with `<!DOCTYPE html>`.

---

#### Step 2: Open the Port in the NSG

**Exit your SSH session** (type `exit`) and run the following from your **local machine**.

Choose **Option A (Portal)** or **Option B (CLI)**:

##### Option A: Using the Azure Portal (Recommended for Beginners)

1. Go to [portal.azure.com](https://portal.azure.com)
2. Search for **"Network security groups"** in the top search bar
3. Click on your NSG (look for `nsg-microk8s-001` or similar)
4. In the left menu, click **Inbound security rules**
5. Click **+ Add** at the top
6. Fill in the form:

   | Field | Value |
   |-------|-------|
   | Source | Any |
   | Source port ranges | `*` |
   | Destination | Any |
   | Service | Custom |
   | Destination port ranges | `31302` (your NodePort) |
   | Protocol | TCP |
   | Action | Allow |
   | Priority | `1100` |
   | Name | `AllowKubernetesNodePort` |

7. Click **Add**

> 💡 **Tip**: You can also find the NSG by going to your Resource Group → clicking the NSG resource directly.

##### Option B: Using Azure CLI (Bash)

```bash
# Set your variables
RESOURCE_GROUP="rg-azure-essentials-dev"
NODE_PORT="31302"  # Replace with YOUR NodePort from Step 1

# Find your NSG name
NSG_NAME=$(az network nsg list -g $RESOURCE_GROUP --query "[?contains(name, 'microk8s')].name" -o tsv)
echo "Found NSG: $NSG_NAME"

# Add the inbound rule
az network nsg rule create \
  --resource-group $RESOURCE_GROUP \
  --nsg-name $NSG_NAME \
  --name AllowKubernetesNodePort \
  --priority 1100 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --destination-port-ranges $NODE_PORT

echo "NSG rule created for port $NODE_PORT"
```

##### Option C: Using Azure CLI (PowerShell)

```powershell
# Set your variables
$RESOURCE_GROUP = "rg-azure-essentials-dev"
$NODE_PORT = "31302"  # Replace with YOUR NodePort from Step 1

# Find your NSG name
$NSG_NAME = az network nsg list -g $RESOURCE_GROUP --query "[?contains(name, 'microk8s')].name" -o tsv
Write-Host "Found NSG: $NSG_NAME"

# Add the inbound rule
az network nsg rule create `
  --resource-group $RESOURCE_GROUP `
  --nsg-name $NSG_NAME `
  --name AllowKubernetesNodePort `
  --priority 1100 `
  --direction Inbound `
  --access Allow `
  --protocol Tcp `
  --destination-port-ranges $NODE_PORT

Write-Host "NSG rule created for port $NODE_PORT"
```

---

#### Step 3: Access from Your Browser

Get your VM's public IP address:

**Bash:**
```bash
VM_IP=$(az vm show -g rg-azure-essentials-dev -n vm-microk8s-001 --show-details --query publicIps -o tsv)
echo "Open in browser: http://$VM_IP:31302"
```

**PowerShell:**
```powershell
$VM_IP = az vm show -g rg-azure-essentials-dev -n vm-microk8s-001 --show-details --query publicIps -o tsv
Write-Host "Open in browser: http://${VM_IP}:31302"
```

**Or via Portal:** Go to your VM in the Azure Portal → **Overview** → copy the **Public IP address**.

Now open your browser and go to:
```
http://<YOUR-VM-IP>:<YOUR-NODE-PORT>
```

**Example:** `http://52.165.62.130:31302`

> 🎉 **Success!** You should see the **Welcome to nginx!** page in your browser!

> ⚠️ **Security Note**: In production, use an Ingress controller with TLS instead of exposing NodePorts directly.

### Exercise 6.4: Explore Kubernetes Resources

**Objective**: Learn to inspect and manage Kubernetes resources.

```bash
# View pod details
kubectl describe pod <pod-name>

# View deployment configuration
kubectl get deployment nginx -o yaml

# View logs from a pod
kubectl logs <pod-name>

# Execute a command in a pod
kubectl exec -it <pod-name> -- /bin/bash

# Inside the pod, test nginx
curl localhost
exit

# Delete the resources
kubectl delete service nginx
kubectl delete deployment nginx
```

---

## Working with YAML Manifests

Create a deployment manifest file:

```yaml
# nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:latest
          ports:
            - containerPort: 80
          resources:
            requests:
              memory: "64Mi"
              cpu: "100m"
            limits:
              memory: "128Mi"
              cpu: "200m"
```

Apply the manifest:

```bash
# Apply the configuration
kubectl apply -f nginx-deployment.yaml

# View the deployment
kubectl get deployment nginx-deployment

# Update the image
kubectl set image deployment/nginx-deployment nginx=nginx:1.25

# Watch the rolling update
kubectl rollout status deployment/nginx-deployment
```

---

## Clean Up

Before leaving the SSH session:

```bash
# Clean up Kubernetes resources
kubectl delete deployment nginx-deployment
kubectl delete service nginx

# Exit SSH
exit
```

From your local machine:

```bash
# Deallocate the VM to stop charges
az vm deallocate \
  --name $VM_NAME \
  --resource-group $RESOURCE_GROUP
```

---

## Key Commands Reference

```bash
# Linux VM
az vm create --image Ubuntu2204 --generate-ssh-keys
ssh <user>@<ip>

# MicroK8s
microk8s status
microk8s enable <addon>
microk8s kubectl <command>

# kubectl basics
kubectl get <resource>
kubectl describe <resource> <name>
kubectl create deployment <name> --image=<image>
kubectl expose deployment <name> --port=<port>
kubectl scale deployment <name> --replicas=<n>
kubectl logs <pod-name>
kubectl exec -it <pod-name> -- <command>
kubectl delete <resource> <name>
kubectl apply -f <file.yaml>
```

---

## Summary

In this lesson, you learned:

- ✅ Deploying Linux VMs on Azure
- ✅ SSH key-based authentication
- ✅ Installing MicroK8s for local Kubernetes
- ✅ Core Kubernetes concepts (pods, deployments, services)
- ✅ Deploying and scaling containerised workloads

---

## Next Steps

Continue to [Lesson 07: Container Services](../07-container-services/README.md) to work with Azure Container Registry and AKS.

---

## Additional Resources

- [Linux VMs on Azure](https://learn.microsoft.com/azure/virtual-machines/linux/)
- [MicroK8s Documentation](https://microk8s.io/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
