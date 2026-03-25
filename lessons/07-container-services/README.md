# Lesson 07: Container Services

> **Duration**: 25 minutes | **Day**: 1

## Overview

Azure provides managed container services for building, storing, and running containerised applications. This lesson covers Azure Container Registry (ACR) and Azure Container Apps.

## Prerequisites

**Deploy Lesson 7 first** using the deploy script:

```bash
./scripts/bash/deploy.sh    # Select option 7
```

This creates your resource group and ACR automatically.

> 💡 **Using Cloud Shell?** Clone the repo first: `git clone https://github.com/codetocloudorg/azure_essentials.git && cd azure_essentials`

---

## Quick Start (After Deployment)

```bash
# 1. Find your ACR (auto-discover)
ACR_NAME=$(az acr list --query "[0].name" -o tsv)
echo "Your ACR: $ACR_NAME"

# 2. Navigate to sample app
cd lessons/07-container-services/src/hello-container

# 3. Build the container (no Docker needed!)
az acr build --registry $ACR_NAME --image hello-container:v1 .

# 4. Verify it worked
az acr repository list --name $ACR_NAME -o table
```

That's it! You've built and stored a container image in Azure.

---

## Learning Objectives

By the end of this lesson, you will be able to:

- Create and configure Azure Container Registry
- Build container images using ACR Tasks (no Docker needed!)
- Deploy containers to Azure Container Apps with a public URL
- Understand container security best practices

---

## Key Concepts

### Azure Container Registry (ACR)

ACR is a managed Docker registry service for storing container images:

| SKU          | Features                      | Use Case             |
| ------------ | ----------------------------- | -------------------- |
| **Basic**    | Entry-level, limited storage  | Development, testing |
| **Standard** | More storage, webhooks        | Small production     |
| **Premium**  | Geo-replication, private link | Enterprise           |

### Azure Container Apps

Container Apps is a serverless container platform — no clusters to manage:

| Feature    | Details                                  |
| ---------- | ---------------------------------------- |
| Pricing    | Consumption plan (~$0 at low traffic)    |
| Scaling    | Scale-to-zero, auto-scale on HTTP/events |
| Ingress    | Built-in HTTPS with custom domains       |
| Complexity | No Kubernetes knowledge required         |

> 💡 For production Kubernetes workloads at scale, see [Azure Kubernetes Service (AKS)](https://learn.microsoft.com/azure/aks/intro-kubernetes).

### Container Workflow

```
Dockerfile → ACR Build → Container Registry → Container Apps
                ↓              ↓                    ↓
         (in the cloud)   (stores images)    (runs containers)
```

---

## Hands-on Exercises

### Exercise 7.1: Discover Your ACR

**Objective**: Find the ACR created by the deploy script.

```bash
# Find your ACR name
ACR_NAME=$(az acr list --query "[0].name" -o tsv)
echo "ACR Name: $ACR_NAME"

# Find your resource group
RG=$(az acr list --query "[0].resourceGroup" -o tsv)
echo "Resource Group: $RG"

# Get the login server
az acr show --name $ACR_NAME --query loginServer -o tsv

# Get admin credentials
az acr credential show --name $ACR_NAME -o table
```

### Exercise 7.2: Build a Container Image

**Objective**: Build a container image using ACR Tasks (no Docker required!).

```bash
# Navigate to the sample app
cd lessons/07-container-services/src/hello-container

# Build the image in ACR
az acr build --registry $ACR_NAME --image hello-container:v1 .

# Verify it was created
az acr repository list --name $ACR_NAME -o table
az acr repository show-tags --name $ACR_NAME --repository hello-container -o table
```

The sample app folder contains:

| File         | Purpose                            |
| ------------ | ---------------------------------- |
| `app.py`     | Flask web app - "Hello from Azure" |
| `Dockerfile` | Container build instructions       |

### Exercise 7.3: Deploy to Azure Container Apps

**Objective**: Deploy your container to the internet with a public URL.

```bash
# Get your resource group
RG=$(az acr list --query "[0].resourceGroup" -o tsv)

# Install containerapp extension
az extension add --name containerapp --upgrade -y

# Create environment and deploy (takes 2-3 minutes)
ENV_NAME="cae-$(openssl rand -hex 4)"
APP_NAME="hello-$(openssl rand -hex 4)"

az containerapp env create --name $ENV_NAME --resource-group $RG --location centralus

az containerapp create \
  --name $APP_NAME \
  --resource-group $RG \
  --environment $ENV_NAME \
  --image $ACR_NAME.azurecr.io/hello-container:v1 \
  --registry-server $ACR_NAME.azurecr.io \
  --registry-username $(az acr credential show -n $ACR_NAME --query username -o tsv) \
  --registry-password $(az acr credential show -n $ACR_NAME --query passwords[0].value -o tsv) \
  --target-port 8080 \
  --ingress external

# Get the public URL
az containerapp show -n $APP_NAME -g $RG --query properties.configuration.ingress.fqdn -o tsv
```

Open the URL in your browser - you should see **"Hello from Azure!"**

### Exercise 7.4: Run Locally with Docker (Optional)

**Objective**: Test locally if you have Docker installed.

**Bash:**

```bash
# Login to ACR
az acr login --name $ACR_NAME

# Pull and run
docker pull $ACR_NAME.azurecr.io/hello-container:v1
docker run -d -p 8080:8080 $ACR_NAME.azurecr.io/hello-container:v1

# Open http://localhost:8080 in your browser
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
az acr list --query "[0].name" -o tsv              # Find your ACR
az acr build --registry <n> --image <img:tag> .    # Build in cloud
az acr repository list --name <n>                  # List images

# Azure Container Apps
az containerapp env create --name <env> --resource-group <rg> --location <loc>
az containerapp create --name <app> --resource-group <rg> --environment <env> \
    --image <acr>.azurecr.io/<img> --target-port 8080 --ingress external
az containerapp show --name <app> -g <rg> --query properties.configuration.ingress.fqdn
az containerapp logs show -n <app> -g <rg>         # View logs
az containerapp update -n <app> -g <rg> --min-replicas 1 --max-replicas 5  # Scale

# Docker (optional - for local testing)
docker run -d -p 8080:8080 <image>
```

---

## Summary

In this lesson, you learned:

- ✅ Building container images with ACR Tasks (no Docker needed!)
- ✅ Storing images in Azure Container Registry
- ✅ Deploying to Azure Container Apps with a public URL
- ✅ Container security best practices

---

## Next Steps

Continue to [Lesson 08: Serverless Services](../08-serverless/README.md) to explore Azure Functions and Logic Apps.

---

## Additional Resources

- [Azure Container Registry Documentation](https://learn.microsoft.com/azure/container-registry/)
- [Azure Container Apps Documentation](https://learn.microsoft.com/azure/container-apps/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
