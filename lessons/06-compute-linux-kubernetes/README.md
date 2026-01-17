# Lesson 06: Compute Services - Linux and Kubernetes

> **Duration**: 25 minutes | **Day**: 1

## Overview

Azure supports a wide range of Linux distributions and Kubernetes workloads. This lesson introduces Linux VMs and provides hands-on experience with MicroK8s for container orchestration.

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

| Distribution | Use Case |
|--------------|----------|
| **Ubuntu** | General purpose, development |
| **Red Hat Enterprise Linux** | Enterprise workloads |
| **Debian** | Stability, servers |
| **CentOS** | RHEL compatibility |
| **SUSE** | SAP workloads |

### Kubernetes Fundamentals

Key Kubernetes concepts:

| Concept | Description |
|---------|-------------|
| **Pod** | Smallest deployable unit (one or more containers) |
| **Deployment** | Manages pod replicas and updates |
| **Service** | Exposes pods to network traffic |
| **Namespace** | Logical isolation within a cluster |
| **ConfigMap/Secret** | Configuration and sensitive data |

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
LOCATION="uksouth"
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
