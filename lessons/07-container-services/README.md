# Lesson 07: Container Services

> **Duration**: 25 minutes | **Day**: 1

## Overview

Azure provides managed container services for building, storing, and orchestrating containerised applications. This lesson covers Azure Container Registry (ACR) and introduces Azure Kubernetes Service (AKS).

## 🚀 Sample Application

This lesson includes a containerized dashboard you can build and deploy:

**[Cloud Dashboard](src/cloud-dashboard/README.md)** - An interactive Azure services status dashboard

```bash
# Build with ACR Tasks (no local Docker needed!)
cd lessons/07-container-services/src/cloud-dashboard
az acr build --registry $ACR_NAME --image cloud-dashboard:v1 .
```

## Learning Objectives

By the end of this lesson, you will be able to:

- Create and configure Azure Container Registry
- Build and push container images to ACR
- Understand Azure Kubernetes Service architecture
- Deploy containers from ACR to orchestration platforms
- Implement container security best practices

---

## Key Concepts

### Azure Container Registry (ACR)

ACR is a managed Docker registry service for storing container images:

| SKU          | Features                      | Use Case             |
| ------------ | ----------------------------- | -------------------- |
| **Basic**    | Entry-level, limited storage  | Development, testing |
| **Standard** | More storage, webhooks        | Small production     |
| **Premium**  | Geo-replication, private link | Enterprise           |

### Azure Kubernetes Service (AKS)

AKS is a managed Kubernetes service:

| Component     | Managed By                   |
| ------------- | ---------------------------- |
| Control plane | Microsoft (free)             |
| Worker nodes  | You (pay for VMs)            |
| Upgrades      | Assisted by Azure            |
| Scaling       | Cluster autoscaler available |

### Container Workflow

```
Local Development → Build Image → Push to ACR → Deploy to AKS
        ↓               ↓              ↓              ↓
   Dockerfile      docker build    docker push    kubectl apply
```

---

## Hands-on Exercises

### Exercise 7.1: Create Azure Container Registry

**Objective**: Create an ACR instance for storing container images.

---

#### Option A: Bash / Cloud Shell

```bash
# Variables
RESOURCE_GROUP="rg-azure-essentials-dev"
LOCATION="centralus"
ACR_NAME="acressentials$(openssl rand -hex 4)"

# Create the container registry
az acr create \
  --name $ACR_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Basic \
  --admin-enabled true

# Get the login server
az acr show \
  --name $ACR_NAME \
  --query loginServer \
  --output tsv

# Get admin credentials
az acr credential show \
  --name $ACR_NAME \
  --output table

# Save the ACR name for later exercises
echo "ACR_NAME=$ACR_NAME"
```

---

#### Option B: PowerShell

```powershell
# Variables
$RESOURCE_GROUP = "rg-azure-essentials-dev"
$LOCATION = "centralus"
$RANDOM_ID = -join ((48..57) + (97..102) | Get-Random -Count 8 | ForEach-Object {[char]$_})
$ACR_NAME = "acressentials$RANDOM_ID"

# Create the container registry
az acr create `
  --name $ACR_NAME `
  --resource-group $RESOURCE_GROUP `
  --location $LOCATION `
  --sku Basic `
  --admin-enabled true

# Get the login server
az acr show `
  --name $ACR_NAME `
  --query loginServer `
  --output tsv

# Get admin credentials
az acr credential show `
  --name $ACR_NAME `
  --output table

# Save the ACR name for later exercises
Write-Host "ACR_NAME=$ACR_NAME - save this for later exercises!"
```

> 💡 **Important**: Copy your `ACR_NAME` value! You'll need it for the remaining exercises.

### Exercise 7.2: Build and Push a Container Image

**Objective**: Build a container image and push it to ACR.

This lesson includes a ready-to-use sample app in `src/hello-container/`. No need to create files manually!

---

#### Step 1: Navigate to the Sample App

**Bash / Cloud Shell:**

```bash
# From the repo root
cd lessons/07-container-services/src/hello-container
```

**PowerShell:**

```powershell
# From the repo root
cd lessons\07-container-services\src\hello-container
```

The folder contains:
| File | Purpose |
|------|---------|
| `app.py` | Flask web app showing "Hello from Azure!" |
| `Dockerfile` | Container build instructions |
| `README.md` | Additional documentation |

---

#### Step 2: Build with ACR Tasks (No Docker Required!)

ACR Tasks builds the container in Azure, so you don't need Docker installed locally.

**Bash / Cloud Shell:**

```bash
# Build the image in ACR
az acr build \
  --registry $ACR_NAME \
  --image hello-container:v1 \
  .
```

**PowerShell:**

```powershell
# Build the image in ACR
az acr build `
  --registry $ACR_NAME `
  --image hello-container:v1 `
  .
```

> 💡 **Tip**: The `.` at the end tells ACR Tasks to use the current directory as the build context.

---

#### Step 3: Verify the Image

**Bash / Cloud Shell:**

```bash
# List images in the registry
az acr repository list --name $ACR_NAME --output table

# Show image tags
az acr repository show-tags \
  --name $ACR_NAME \
  --repository hello-container \
  --output table
```

**PowerShell:**

```powershell
# List images in the registry
az acr repository list --name $ACR_NAME --output table

# Show image tags
az acr repository show-tags `
  --name $ACR_NAME `
  --repository hello-container `
  --output table
```

---

#### Step 4: Return to Repo Root

**Bash:**

```bash
cd ../../../..
```

**PowerShell:**

```powershell
cd ..\..\..\..
```

### Exercise 7.3: Deploy to Azure Container Apps (Internet Accessible!)

**Objective**: Deploy your container to Azure Container Apps with a public URL.

Azure Container Apps is the easiest way to run containers with a public endpoint.

---

#### Option A: Bash / Cloud Shell

```bash
# First, ensure the containerapp extension is installed
az extension add --name containerapp --upgrade -y

# Variables
RESOURCE_GROUP="rg-azure-essentials-dev"
LOCATION="centralus"
RANDOM_ID=$(openssl rand -hex 4)
ENV_NAME="cae-essentials-$RANDOM_ID"
APP_NAME="hello-app-$RANDOM_ID"

# Create Container Apps environment (takes 1-2 minutes)
az containerapp env create \
  --name $ENV_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION

# Deploy container from ACR with public ingress
az containerapp create \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --environment $ENV_NAME \
  --image $ACR_NAME.azurecr.io/hello-container:v1 \
  --registry-server $ACR_NAME.azurecr.io \
  --registry-username $(az acr credential show -n $ACR_NAME --query username -o tsv) \
  --registry-password $(az acr credential show -n $ACR_NAME --query passwords[0].value -o tsv) \
  --target-port 8080 \
  --ingress external \
  --min-replicas 1 \
  --max-replicas 3

# Get the public URL
APP_URL=$(az containerapp show -n $APP_NAME -g $RESOURCE_GROUP --query properties.configuration.ingress.fqdn -o tsv)
echo "Your app is live at: https://$APP_URL"
```

---

#### Option B: PowerShell

```powershell
# First, ensure the containerapp extension is installed
az extension add --name containerapp --upgrade -y

# Variables
$RESOURCE_GROUP = "rg-azure-essentials-dev"
$LOCATION = "centralus"
$RANDOM_ID = -join ((48..57) + (97..102) | Get-Random -Count 8 | ForEach-Object {[char]$_})
$ENV_NAME = "cae-essentials-$RANDOM_ID"
$APP_NAME = "hello-app-$RANDOM_ID"

# Create Container Apps environment (takes 1-2 minutes)
az containerapp env create `
  --name $ENV_NAME `
  --resource-group $RESOURCE_GROUP `
  --location $LOCATION

# Get ACR credentials
$ACR_USERNAME = az acr credential show -n $ACR_NAME --query username -o tsv
$ACR_PASSWORD = az acr credential show -n $ACR_NAME --query "passwords[0].value" -o tsv

# Deploy container from ACR with public ingress
az containerapp create `
  --name $APP_NAME `
  --resource-group $RESOURCE_GROUP `
  --environment $ENV_NAME `
  --image "$ACR_NAME.azurecr.io/hello-container:v1" `
  --registry-server "$ACR_NAME.azurecr.io" `
  --registry-username $ACR_USERNAME `
  --registry-password $ACR_PASSWORD `
  --target-port 8080 `
  --ingress external `
  --min-replicas 1 `
  --max-replicas 3

# Get the public URL
$APP_URL = az containerapp show -n $APP_NAME -g $RESOURCE_GROUP --query properties.configuration.ingress.fqdn -o tsv
Write-Host "Your app is live at: https://$APP_URL"
```

---

#### Step 3: View Your App

Open the URL in your browser. You should see **"Hello from Azure!"** with the container hostname.

> ✅ **Success!** Your container is now running on Azure with HTTPS and auto-scaling!

### Exercise 7.4: Run Container Locally (Optional)

**Objective**: Test the container image locally if you have Docker installed.

**Bash:**

```bash
# Login to ACR
az acr login --name $ACR_NAME

# Pull and run the image
docker pull $ACR_NAME.azurecr.io/hello-container:v1
docker run -d -p 8080:8080 $ACR_NAME.azurecr.io/hello-container:v1

# Test the application
curl http://localhost:8080

# Stop the container
docker stop $(docker ps -q --filter ancestor=$ACR_NAME.azurecr.io/hello-container:v1)
```

**PowerShell:**

```powershell
# Login to ACR
az acr login --name $ACR_NAME

# Pull and run the image
docker pull "$ACR_NAME.azurecr.io/hello-container:v1"
docker run -d -p 8080:8080 "$ACR_NAME.azurecr.io/hello-container:v1"

# Test the application (open in browser)
Start-Process "http://localhost:8080"

# Stop the container
docker stop (docker ps -q --filter "ancestor=$ACR_NAME.azurecr.io/hello-container:v1")
```

### Exercise 7.5: Explore AKS Concepts

**Objective**: Understand AKS architecture and create a cluster overview.

```bash
# View available Kubernetes versions
az aks get-versions \
  --location $LOCATION \
  --output table

# View available VM sizes for AKS nodes
az vm list-sizes \
  --location $LOCATION \
  --query "[?numberOfCores <= \`4\`].{Name:name, Cores:numberOfCores, Memory:memoryInMb}" \
  --output table
```

> **Note**: Creating a full AKS cluster takes 10-15 minutes and incurs costs. In a production exercise, you would create the cluster with:

```bash
# Example: Create AKS cluster (for reference)
# az aks create \
#   --name aks-azure-essentials \
#   --resource-group $RESOURCE_GROUP \
#   --location $LOCATION \
#   --node-count 2 \
#   --node-vm-size Standard_B2s \
#   --generate-ssh-keys \
#   --attach-acr $ACR_NAME
```

---

## Dockerfile Best Practices

Follow these practices for production containers:

```dockerfile
# 1. Use specific base image versions
FROM python:3.13-slim

# 2. Set working directory
WORKDIR /app

# 3. Copy dependency files first (better caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. Copy application code
COPY . .

# 5. Create non-root user
RUN useradd --create-home appuser
USER appuser

# 6. Document the exposed port
EXPOSE 8080

# 7. Use explicit command
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]
```

---

## Container Security Checklist

| Practice                    | Description                  |
| --------------------------- | ---------------------------- |
| ✅ Use official base images | Start from trusted sources   |
| ✅ Scan for vulnerabilities | Use ACR's built-in scanning  |
| ✅ Run as non-root          | Reduce container privileges  |
| ✅ Use specific tags        | Avoid `latest` in production |
| ✅ Keep images small        | Remove unnecessary packages  |
| ✅ Sign images              | Use content trust            |

---

## Key Commands Reference

```bash
# Azure Container Registry
az acr create --name <n> --sku Basic --admin-enabled true
az acr login --name <n>
az acr build --registry <n> --image <img:tag> .
az acr repository list --name <n>
az acr repository show-tags --name <n> --repository <repo>

# Docker commands
docker build -t <image:tag> .
docker push <registry>/<image:tag>
docker pull <registry>/<image:tag>
docker run -d -p <host>:<container> <image>

# AKS (reference)
az aks create --name <n> --node-count <n>
az aks get-credentials --name <n> --resource-group <rg>
kubectl get nodes
```

---

## Summary

In this lesson, you learned:

- ✅ Creating Azure Container Registry
- ✅ Building container images with ACR Tasks
- ✅ Container image management and tagging
- ✅ Azure Kubernetes Service architecture
- ✅ Container security best practices

---

## Next Steps

Continue to [Lesson 08: Serverless Services](../08-serverless/README.md) to explore Azure Functions and Logic Apps.

---

## Additional Resources

- [Azure Container Registry Documentation](https://learn.microsoft.com/azure/container-registry/)
- [Azure Kubernetes Service Documentation](https://learn.microsoft.com/azure/aks/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
