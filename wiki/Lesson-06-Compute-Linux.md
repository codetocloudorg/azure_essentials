# Lesson 06: Linux VM & MicroK8s

> **Time:** 45 minutes | **Difficulty:** Medium | **Cost:** ~$5/day for VM

## 🎯 What You'll Build

By the end of this lesson, you'll have:
- Created a Linux VM in Azure
- Installed MicroK8s (lightweight Kubernetes)
- Deployed a container that's accessible from the internet
- Learned the basics of Kubernetes

---

## 🐧 Linux vs Windows VMs

| Feature | Windows | Linux |
|---------|---------|-------|
| Remote access | RDP (port 3389) | SSH (port 22) |
| Cost | Higher (licensing) | Lower |
| Common for | .NET apps, enterprise | Web servers, containers |
| Management | GUI + PowerShell | Terminal + scripts |

---

## 🏗️ Create a Linux VM

### Step 1: Set Up Variables

```bash
# Configuration
RG_NAME="rg-linux-lesson"
LOCATION="centralus"
VM_NAME="vm-linux-microk8s"
ADMIN_USER="azureuser"

# Create resource group
az group create --name $RG_NAME --location $LOCATION
```

### Step 2: Create the VM

```bash
az vm create \
  --resource-group $RG_NAME \
  --name $VM_NAME \
  --image Ubuntu2404 \
  --size Standard_D2s_v3 \
  --admin-username $ADMIN_USER \
  --generate-ssh-keys \
  --public-ip-sku Standard
```

**What this creates:**
- Ubuntu 24.04 VM
- 2 vCPUs, 8 GB RAM
- SSH keys generated automatically
- Public IP address assigned

### Step 3: Note the Public IP

The command output includes `publicIpAddress`. Save it!

```bash
# Or get it later:
az vm list-ip-addresses --name $VM_NAME --resource-group $RG_NAME --output table
```

---

## 🔑 Connect via SSH

### From Mac/Linux

```bash
ssh azureuser@<PUBLIC_IP_ADDRESS>
```

### From Windows

Use PowerShell (Windows 10+):
```powershell
ssh azureuser@<PUBLIC_IP_ADDRESS>
```

Or use [Windows Terminal](https://aka.ms/terminal) or PuTTY.

### First Connection

You'll see:
```
The authenticity of host '...' can't be established.
Are you sure you want to continue connecting (yes/no)?
```

Type `yes` and press Enter.

---

## 🚀 Install MicroK8s

MicroK8s is "Kubernetes in a box" - perfect for learning!

### Step 1: Update System & Install

```bash
# Update packages
sudo apt update && sudo apt upgrade -y

# Install MicroK8s
sudo snap install microk8s --classic

# Add your user to the microk8s group
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube

# Apply group changes (relogin)
newgrp microk8s
```

### Step 2: Wait for Ready

```bash
microk8s status --wait-ready
```

You should see:
```
microk8s is running
```

### Step 3: Enable Essential Addons

```bash
microk8s enable dns storage
```

---

## 📦 Deploy Your First Container

### Step 1: Create a Hello World Deployment

```bash
# Create a simple nginx deployment
microk8s kubectl create deployment hello-world --image=nginx:alpine

# Check it's running
microk8s kubectl get pods
```

Wait until STATUS shows `Running`:
```
NAME                          READY   STATUS    RESTARTS   AGE
hello-world-...-xxxxx         1/1     Running   0          30s
```

### Step 2: Expose It Inside the Cluster

```bash
# Expose as a service
microk8s kubectl expose deployment hello-world \
  --type=NodePort \
  --port=80

# See the service
microk8s kubectl get services
```

Output:
```
NAME          TYPE       CLUSTER-IP      PORT(S)        AGE
hello-world   NodePort   10.152.183.xx   80:30XXX/TCP   5s
```

Note the NodePort number (30XXX). Mine might be `30742`.

---

## 🌐 Make It Internet Accessible

By default, Azure blocks incoming traffic. Let's open the NodePort!

### Step 1: Get Your NodePort

```bash
microk8s kubectl get svc hello-world -o jsonpath='{.spec.ports[0].nodePort}'
```

Example output: `30742`

### Step 2: Open the Port in Azure NSG

**Run these commands from your local machine** (not the VM):

```bash
# Get the NSG name (it's usually VM_NAME + NSG)
NSG_NAME=$(az network nsg list --resource-group $RG_NAME --query "[0].name" -o tsv)

# Create rule to allow your NodePort
az network nsg rule create \
  --resource-group $RG_NAME \
  --nsg-name $NSG_NAME \
  --name AllowNodePort \
  --priority 900 \
  --source-address-prefixes Internet \
  --destination-port-ranges 30000-32767 \
  --access Allow \
  --protocol Tcp \
  --direction Inbound
```

### Step 3: Test It!

Open your browser and go to:
```
http://<VM_PUBLIC_IP>:<NODEPORT>
```

Example: `http://52.182.xxx.xxx:30742`

🎉 **You should see the nginx welcome page!**

---

## 💻 Kubernetes Cheat Sheet

Common commands you'll use:

| Command | What It Does |
|---------|--------------|
| `microk8s kubectl get pods` | List all pods |
| `microk8s kubectl get services` | List all services |
| `microk8s kubectl get deployments` | List all deployments |
| `microk8s kubectl describe pod <name>` | Detailed pod info |
| `microk8s kubectl logs <pod-name>` | View pod logs |
| `microk8s kubectl delete deployment <name>` | Delete a deployment |

### Create an Alias (Easier Typing)

```bash
# Add to ~/.bashrc
alias k='microk8s kubectl'

# Then use:
k get pods
k get svc
```

---

## 📄 Using YAML Files

Instead of commands, you can use YAML files. Create `app.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: app
        image: nginx:alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: my-app
spec:
  type: NodePort
  selector:
    app: my-app
  ports:
  - port: 80
    targetPort: 80
```

Apply it:
```bash
microk8s kubectl apply -f app.yaml
```

---

## 🔍 Troubleshooting

### Pod Stuck in Pending

```bash
# Check what's wrong
microk8s kubectl describe pod <pod-name>

# Look at the Events section at the bottom
```

### Can't Access from Internet

1. Check pod is running: `microk8s kubectl get pods`
2. Check service exists: `microk8s kubectl get svc`
3. Check NSG rule in Azure Portal
4. Make sure you're using the NodePort, not port 80

### MicroK8s Not Starting

```bash
# Check status with more detail
microk8s inspect

# Try restarting
microk8s stop
microk8s start
```

---

## 🧹 Clean Up

### Delete Kubernetes Resources

```bash
microk8s kubectl delete deployment hello-world
microk8s kubectl delete service hello-world
```

### Delete Azure Resources

```bash
az group delete --name $RG_NAME --yes
```

---

## ✅ What You Learned

- 🐧 How to create a Linux VM in Azure
- 🔑 How to connect via SSH
- 🚀 How to install MicroK8s (mini Kubernetes)
- 📦 How to deploy containers
- 🌐 How to expose services to the internet

---

## ➡️ Next Steps

Ready for managed container services?

👉 **[Lesson 07: Container Services](Lesson-07-Containers)**

---

*Questions? Join our [Discord](https://discord.gg/vwfwq2EpXJ) community!*
