# Hello Container - Azure Essentials

A minimal "Hello World" container for learning Azure Container Registry and AKS.

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
- Has a `/health` endpoint for Kubernetes health checks

## Files

| File | Purpose |
|------|---------|
| `app.py` | Flask web application |
| `Dockerfile` | Container build instructions |

## Deploy to AKS

```yaml
# kubernetes/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-container
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello-container
  template:
    spec:
      containers:
      - name: hello-container
        image: <acr-name>.azurecr.io/hello-container:v1
        ports:
        - containerPort: 8080
```
