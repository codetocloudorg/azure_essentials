# Lesson 07: Container Services

> **Time:** 30 minutes | **Difficulty:** Medium | **Cost:** ~$0.10

## 🎯 What You'll Build

By the end of this lesson, you'll have:
- Built a container image in Azure (no Docker install needed!)
- Deployed a web app to Azure Container Apps
- Accessed your app via a public HTTPS URL

---

## 🐳 What Are Containers?

### The Problem They Solve

Ever heard "but it works on my computer"? Containers fix that!

| Without Containers | With Containers |
|-------------------|-----------------|
| "Install Python 3.9, then install Flask, then configure..." | "Run this container" |
| Works on your laptop, breaks on server | Works exactly the same everywhere |
| Takes hours to set up | Takes seconds to start |

### Containers vs Virtual Machines

| Container | Virtual Machine |
|-----------|-----------------|
| Shares the host's OS kernel | Has its own complete OS |
| Starts in seconds | Starts in minutes |
| Megabytes in size | Gigabytes in size |
| Best for: single applications | Best for: full environments |

Think of it this way:
- **VM** = A whole apartment (has kitchen, bathroom, etc.)
- **Container** = A hotel room (shares building facilities)

---

## 📦 Container Vocabulary

| Term | Simple Definition |
|------|-------------------|
| **Container** | A packaged application with all its dependencies |
| **Image** | A template/snapshot used to create containers |
| **Registry** | A library where images are stored (like GitHub for code) |
| **Dockerfile** | Instructions for building an image (like a recipe) |

---

## 🏗️ Azure Container Services

Azure offers several ways to run containers:

| Service | Best For | Complexity |
|---------|----------|------------|
| **Azure Container Apps** | Web apps, APIs, microservices | ⭐ Easy |
| **Azure Container Instances** | Quick, simple containers | ⭐ Easy |
| **Azure Kubernetes Service (AKS)** | Complex, large-scale apps | ⭐⭐⭐ Advanced |

**This lesson uses Container Apps** - perfect for beginners!

---

## 🛠️ Let's Deploy a Container!

### Step 0: Install Required Extension

First, make sure you have the Container Apps extension:

```bash
az extension add --name containerapp --upgrade -y
```

### Step 1: Set Variables

```bash
RESOURCE_GROUP="rg-container-lesson"
LOCATION="centralus"
ACR_NAME="acr$(openssl rand -hex 4)"  # Must be globally unique
```

### Step 2: Create Resource Group

```bash
az group create --name $RESOURCE_GROUP --location $LOCATION
```

### Step 3: Create a Container Registry (ACR)

Azure Container Registry is like "Docker Hub but private":

```bash
az acr create \
  --name $ACR_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Basic \
  --admin-enabled true

echo "Your registry is: $ACR_NAME.azurecr.io"
```

### Step 4: Build a Container Image

Here's the cool part - **you don't need Docker installed!** Azure can build images for you:

```bash
# Create a simple web app
mkdir hello-app && cd hello-app

# Create the Python application
cat > app.py << 'EOF'
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return '''
    <html>
    <head><title>Hello Container!</title></head>
    <body style="font-family: Arial; text-align: center; padding: 50px; 
                 background: linear-gradient(135deg, #667eea, #764ba2); color: white;">
        <h1>🐳 Hello from Azure Container Apps!</h1>
        <p>You did it! This is running in a container.</p>
    </body>
    </html>
    '''

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

Now build it in Azure:

```bash
az acr build \
  --registry $ACR_NAME \
  --image hello-app:v1 \
  .
```

⏳ Wait 1-2 minutes while Azure builds your container!

### Step 5: Deploy to Container Apps

```bash
# Create Container Apps environment
ENV_NAME="cae-lesson-$(openssl rand -hex 4)"

az containerapp env create \
  --name $ENV_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION
```

⏳ This takes 2-3 minutes.

```bash
# Get ACR credentials
ACR_PASSWORD=$(az acr credential show -n $ACR_NAME --query "passwords[0].value" -o tsv)

# Deploy the container
APP_NAME="hello-app-$(openssl rand -hex 4)"

az containerapp create \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --environment $ENV_NAME \
  --image "$ACR_NAME.azurecr.io/hello-app:v1" \
  --registry-server "$ACR_NAME.azurecr.io" \
  --registry-username $ACR_NAME \
  --registry-password "$ACR_PASSWORD" \
  --target-port 8080 \
  --ingress external \
  --min-replicas 1 \
  --max-replicas 3
```

### Step 6: Get Your App URL!

```bash
az containerapp show \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --query "properties.configuration.ingress.fqdn" \
  --output tsv
```

**Open that URL in your browser!** 🎉

Your app is now live on the internet with:
- ✅ HTTPS (secure)
- ✅ Auto-scaling (handles traffic spikes)
- ✅ Load balancing (distributes requests)
- ✅ Zero infrastructure to manage

---

## 📊 See It in the Portal

1. Go to [portal.azure.com](https://portal.azure.com)
2. Search for **Container Apps**
3. Click your app
4. See **Overview** for URL and status
5. Check **Logs** for application output
6. View **Metrics** for performance data

---

## 🔄 Update Your App

Want to make changes? Just rebuild and redeploy:

```bash
# Edit app.py, then rebuild
az acr build --registry $ACR_NAME --image hello-app:v2 .

# Update the container app
az containerapp update \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --image "$ACR_NAME.azurecr.io/hello-app:v2"
```

Container Apps handles **zero-downtime updates** automatically!

---

## 🧹 Clean Up

```bash
cd ..  # Exit hello-app directory
rm -rf hello-app

az group delete --name rg-container-lesson --yes --no-wait
```

---

## ❌ Common Problems & Fixes

### "containerapp: command not found"

**Problem:** CLI extension not installed.

**Fix:**
```bash
az extension add --name containerapp --upgrade -y
```

---

### "Unauthorized" when building image

**Problem:** Not logged into ACR or ACR doesn't exist.

**Fix:**
```bash
# Check ACR exists
az acr list -o table

# Login to ACR (not always needed for az acr build)
az acr login --name $ACR_NAME
```

---

### App shows "Service Unavailable"

**Problem:** Container failed to start. 

**Fix:** Check the logs:
```bash
az containerapp logs show \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP
```

Common causes:
- Port mismatch (app runs on wrong port)
- Missing dependencies
- Crash at startup

---

### "Resource provider not registered"

**Problem:** Microsoft.App provider not registered.

**Fix:**
```bash
az provider register --namespace Microsoft.App --wait
az provider register --namespace Microsoft.ContainerRegistry --wait
```

---

## ✅ What You Learned

- 🐳 What containers are and why they're useful
- 📦 How to build container images using ACR Tasks (no Docker needed!)
- 🚀 How to deploy to Azure Container Apps
- 🔄 How to update running applications
- 🌐 How to get a public HTTPS URL for your app

---

## 📖 Key Terms

| Term | Meaning |
|------|---------|
| **Container** | Packaged application with its dependencies |
| **Image** | Template for creating containers |
| **ACR** | Azure Container Registry - stores your images |
| **Container Apps** | Azure's serverless container platform |
| **Ingress** | How external traffic reaches your app |

---

## ➡️ Next Steps

Ready for serverless? Functions are even simpler:

👉 **[Lesson 08: Serverless](Lesson-08-Serverless)**

---

*Questions? Join our [Discord](https://discord.gg/vwfwq2EpXJ) community!*
