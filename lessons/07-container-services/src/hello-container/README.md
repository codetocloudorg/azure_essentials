# Hello Container - Azure Essentials

A minimal "Hello World" container for learning Azure Container Registry and Container Apps.

## Quick Start

### Option 1: Build in ACR (No Docker Required!)

```bash
# Set your ACR name (from lesson deployment)
ACR_NAME="acressentials<your-id>"

# Build directly in Azure
az acr build --registry $ACR_NAME --image hello-container:v1 .

# Verify the image
az acr repository list --name $ACR_NAME -o table
```

### Option 2: Build Locally with Docker

```bash
# Build
docker build -t hello-container:v1 .

# Run locally
docker run -p 8080:8080 hello-container:v1

# Open http://localhost:8080
```

## What This App Does

- Shows a "Hello from Azure!" page
- Displays the container hostname
- Has a `/health` endpoint for health checks

## Files

| File | Purpose |
|------|---------|
| `app.py` | Flask web application |
| `Dockerfile` | Container build instructions |
| `k8s-deployment.yaml` | Kubernetes manifest (optional, for AKS/MicroK8s) |

## Deploy to Container Apps

```bash
# Set variables
ACR_NAME="<your-acr-name>"
RG="<your-resource-group>"

# Create environment and deploy
az containerapp env create --name my-env --resource-group $RG --location centralus
az containerapp create \
  --name hello-container \
  --resource-group $RG \
  --environment my-env \
  --image $ACR_NAME.azurecr.io/hello-container:v1 \
  --registry-server $ACR_NAME.azurecr.io \
  --target-port 8080 \
  --ingress external

# Get the URL
az containerapp show -n hello-container -g $RG --query properties.configuration.ingress.fqdn -o tsv
```
