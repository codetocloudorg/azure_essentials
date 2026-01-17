# Lesson 07: Container Services

> **Duration**: 25 minutes | **Day**: 1

## Overview

Azure provides managed container services for building, storing, and orchestrating containerised applications. This lesson covers Azure Container Registry (ACR) and introduces Azure Kubernetes Service (AKS).

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

| SKU | Features | Use Case |
|-----|----------|----------|
| **Basic** | Entry-level, limited storage | Development, testing |
| **Standard** | More storage, webhooks | Small production |
| **Premium** | Geo-replication, private link | Enterprise |

### Azure Kubernetes Service (AKS)

AKS is a managed Kubernetes service:

| Component | Managed By |
|-----------|-----------|
| Control plane | Microsoft (free) |
| Worker nodes | You (pay for VMs) |
| Upgrades | Assisted by Azure |
| Scaling | Cluster autoscaler available |

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

```bash
# Variables
RESOURCE_GROUP="rg-azure-essentials-dev"
LOCATION="uksouth"
ACR_NAME="crazessentials$(openssl rand -hex 4)"

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
```

### Exercise 7.2: Build and Push a Container Image

**Objective**: Create a simple application and push it to ACR.

First, create a sample application:

```bash
# Create a directory for the sample app
mkdir -p sample-container && cd sample-container

# Create a simple Python web application
cat > app.py << 'EOF'
from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return f"Hello from Azure Container Registry! Host: {os.environ.get('HOSTNAME', 'unknown')}"

@app.route('/health')
def health():
    return "OK", 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
EOF

# Create requirements file
cat > requirements.txt << 'EOF'
flask==3.0.0
gunicorn==21.2.0
EOF

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 8080

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]
EOF
```

Build and push using ACR Tasks (no local Docker required):

```bash
# Build directly in Azure using ACR Tasks
az acr build \
  --registry $ACR_NAME \
  --image sample-app:v1 \
  --file Dockerfile \
  .

# List images in the registry
az acr repository list \
  --name $ACR_NAME \
  --output table

# Show image tags
az acr repository show-tags \
  --name $ACR_NAME \
  --repository sample-app \
  --output table

# Go back to parent directory
cd ..
```

### Exercise 7.3: Run Container Locally (Optional)

**Objective**: Test the container image locally if you have Docker installed.

```bash
# Login to ACR
az acr login --name $ACR_NAME

# Pull and run the image
docker pull $ACR_NAME.azurecr.io/sample-app:v1
docker run -d -p 8080:8080 $ACR_NAME.azurecr.io/sample-app:v1

# Test the application
curl http://localhost:8080

# Stop the container
docker stop $(docker ps -q --filter ancestor=$ACR_NAME.azurecr.io/sample-app:v1)
```

### Exercise 7.4: Explore AKS Concepts

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
FROM python:3.11-slim

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

| Practice | Description |
|----------|-------------|
| ✅ Use official base images | Start from trusted sources |
| ✅ Scan for vulnerabilities | Use ACR's built-in scanning |
| ✅ Run as non-root | Reduce container privileges |
| ✅ Use specific tags | Avoid `latest` in production |
| ✅ Keep images small | Remove unnecessary packages |
| ✅ Sign images | Use content trust |

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
