# ☁️ Cloud Dashboard

> **Code to Cloud** | Azure Essentials - Lesson 07 Sample Application

A containerized status dashboard showcasing Azure services. Build and push to Azure Container Registry to learn container workflows!

---

## 🎯 What This App Does

- Displays an interactive cloud services dashboard
- Shows simulated Azure service status
- Demonstrates container best practices
- Features Code to Cloud branding

---

## 🚀 Quick Start

### Build Locally

```bash
cd lessons/07-container-services/src/cloud-dashboard

# Build the container
docker build -t cloud-dashboard:v1 .

# Run locally
docker run -d -p 8080:80 cloud-dashboard:v1
```

Visit: http://localhost:8080

### Push to Azure Container Registry

```bash
# Set variables
ACR_NAME="acressentials$(openssl rand -hex 4)"
RESOURCE_GROUP="rg-essentials-containers"

# Create ACR
az acr create --name $ACR_NAME --resource-group $RESOURCE_GROUP --sku Basic

# Build and push using ACR Tasks (no local Docker needed!)
az acr build --registry $ACR_NAME --image cloud-dashboard:v1 .

# View the image
az acr repository list --name $ACR_NAME
```

---

## 📦 Container Details

| Property | Value |
|----------|-------|
| Base Image | `nginx:alpine` |
| Exposed Port | `80` |
| Size | ~25MB |
| Health Check | `GET /` |

---

## 🏗️ Project Structure

```
cloud-dashboard/
├── Dockerfile           # Container build instructions
├── index.html           # Dashboard UI
├── styles.css           # Styling
├── app.js               # Dashboard logic
└── README.md            # This file
```

---

## 🎓 Learning Objectives

By building this container, you'll learn:

1. How to write a Dockerfile
2. How to build container images
3. How to use Azure Container Registry
4. How to use ACR Tasks for cloud builds

---

<p align="center">
  <strong>Code to Cloud Inc.</strong> | Containerize everything
</p>
