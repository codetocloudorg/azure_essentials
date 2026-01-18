# Lesson 07: Container Services - Copy-Paste Commands

---

## 📋 Setup Variables

Copy and paste this block first to set up your variables:

```bash
# Configuration
LOCATION="centralus"
RESOURCE_GROUP="rg-essentials-containers"
UNIQUE_SUFFIX=$(openssl rand -hex 4)
ACR_NAME="acressentials${UNIQUE_SUFFIX}"

# Display the ACR name (save this!)
echo "Container Registry: $ACR_NAME"
```

---

## Step 1: Create Resource Group

```bash
# Create the resource group
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --tags "course=azure-essentials" "lesson=07-containers"
```

---

## Step 2: Create Azure Container Registry

```bash
# Create Container Registry (Basic SKU)
az acr create \
    --name "$ACR_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku Basic \
    --admin-enabled true
```

---

## Step 3: Get ACR Credentials

```bash
# Get the login server URL
az acr show \
    --name "$ACR_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query loginServer \
    -o tsv
```

```bash
# Get admin credentials
az acr credential show \
    --name "$ACR_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query "{Username:username, Password:passwords[0].value}" \
    -o table
```

---

## Step 4: Login to ACR

```bash
# Login to the container registry
az acr login --name "$ACR_NAME"
```

---

## Step 5: Create a Sample Dockerfile

```bash
# Create a simple Dockerfile
cat << 'EOF' > /tmp/Dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
EOF

# Create a sample HTML page
cat << 'EOF' > /tmp/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Azure Essentials</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
        h1 { color: #0078d4; }
    </style>
</head>
<body>
    <h1>Hello from Azure Container Registry!</h1>
    <p>This container was built and pushed using Azure CLI.</p>
</body>
</html>
EOF
```

---

## Step 6: Build and Push Image with ACR Tasks

```bash
# Build the image directly in ACR (no local Docker needed!)
az acr build \
    --registry "$ACR_NAME" \
    --image "essentials-web:v1" \
    --file /tmp/Dockerfile \
    /tmp
```

---

## Step 7: List Images in Registry

```bash
# List repositories
az acr repository list \
    --name "$ACR_NAME" \
    -o table
```

```bash
# Show image tags
az acr repository show-tags \
    --name "$ACR_NAME" \
    --repository "essentials-web" \
    -o table
```

---

## Step 8: View Image Details

```bash
# Show image manifest
az acr repository show \
    --name "$ACR_NAME" \
    --image "essentials-web:v1"
```

---

## Part 2: Run Container (Optional - Requires Docker)

> ℹ️ This section requires Docker installed locally. Skip if using Cloud Shell.

### Pull and Run the Image Locally

```bash
# Get the login server
LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer -o tsv)

# Pull the image
docker pull ${LOGIN_SERVER}/essentials-web:v1

# Run the container
docker run -d -p 8080:80 ${LOGIN_SERVER}/essentials-web:v1

# Visit http://localhost:8080
```

---

## 📊 View ACR Information

```bash
# Show ACR details
az acr show \
    --name "$ACR_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query "{Name:name, LoginServer:loginServer, SKU:sku.name, AdminEnabled:adminUserEnabled}" \
    -o table
```

```bash
# Check ACR usage
az acr show-usage \
    --name "$ACR_NAME" \
    -o table
```

---

## 📚 Additional Commands

### Tag and Push an Image (Alternative Method)

If you built an image locally with Docker:

```bash
# Tag the image
docker tag myimage:latest ${LOGIN_SERVER}/myimage:v1

# Push to ACR
docker push ${LOGIN_SERVER}/myimage:v1
```

### Delete an Image

```bash
# Delete a specific tag
az acr repository delete \
    --name "$ACR_NAME" \
    --image "essentials-web:v1" \
    --yes
```

### Enable Content Trust

```bash
# Enable content trust (Premium SKU only)
# az acr config content-trust update --name "$ACR_NAME" --status enabled
```

### View Build Logs

```bash
# List recent build tasks
az acr task list-runs \
    --registry "$ACR_NAME" \
    -o table
```

---

## 🧹 Cleanup

```bash
# Delete the entire resource group
az group delete \
    --name "$RESOURCE_GROUP" \
    --yes \
    --no-wait

echo "Cleanup initiated - resources deleting in background"
```

```bash
# Clean up temp files
rm -f /tmp/Dockerfile /tmp/index.html
```

---

## 🔗 Quick Reference

| Command | Description |
|---------|-------------|
| `az acr create` | Create container registry |
| `az acr login` | Login to registry |
| `az acr build` | Build image in ACR (no Docker needed) |
| `az acr repository list` | List all repositories |
| `az acr repository show-tags` | List image tags |
| `az acr credential show` | Get admin credentials |
| `az acr show-usage` | View storage usage |

---

## 🏗️ ACR SKU Comparison

| Feature | Basic | Standard | Premium |
|---------|-------|----------|---------|
| Storage | 10 GB | 100 GB | 500 GB |
| Webhooks | 2 | 10 | 500 |
| Geo-replication | ❌ | ❌ | ✅ |
| Content Trust | ❌ | ❌ | ✅ |
| Private Link | ❌ | ❌ | ✅ |
