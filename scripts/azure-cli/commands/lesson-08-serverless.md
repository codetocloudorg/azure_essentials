# Lesson 08: Serverless Services - Copy-Paste Commands

> Azure Functions, triggers, bindings, and Logic Apps

---

## 📋 Setup Variables

Copy and paste this block first to set up your variables:

```bash
# Configuration
LOCATION="centralus"
RESOURCE_GROUP="rg-essentials-serverless"
UNIQUE_SUFFIX=$(openssl rand -hex 4)
STORAGE_ACCOUNT="stfunc${UNIQUE_SUFFIX}"
FUNCTION_APP="func-essentials-${UNIQUE_SUFFIX}"

# Display names (save these!)
echo "Storage Account: $STORAGE_ACCOUNT"
echo "Function App: $FUNCTION_APP"
```

---

## Step 1: Create Resource Group

```bash
# Create the resource group
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --tags "course=azure-essentials" "lesson=08-serverless"
```

---

## Step 2: Create Storage Account

Azure Functions requires a storage account for state management:

```bash
# Create storage account for the function app
az storage account create \
    --name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --kind StorageV2
```

---

## Step 3: Create Function App

```bash
# Create a Python function app (Consumption plan)
az functionapp create \
    --name "$FUNCTION_APP" \
    --resource-group "$RESOURCE_GROUP" \
    --storage-account "$STORAGE_ACCOUNT" \
    --consumption-plan-location "$LOCATION" \
    --runtime python \
    --runtime-version 3.11 \
    --functions-version 4 \
    --os-type Linux
```

---

## Step 4: Get Function App URL

```bash
# Get the default hostname
az functionapp show \
    --name "$FUNCTION_APP" \
    --resource-group "$RESOURCE_GROUP" \
    --query defaultHostName \
    -o tsv
```

---

## Step 5: Configure App Settings

```bash
# Add application settings
az functionapp config appsettings set \
    --name "$FUNCTION_APP" \
    --resource-group "$RESOURCE_GROUP" \
    --settings "ENVIRONMENT=Development" "COURSE=AzureEssentials"
```

---

## Step 6: Create a Simple HTTP Trigger Function

First, create the function code:

```bash
# Create a directory for the function
mkdir -p /tmp/func-app/HttpTrigger

# Create host.json
cat << 'EOF' > /tmp/func-app/host.json
{
    "version": "2.0",
    "logging": {
        "applicationInsights": {
            "samplingSettings": {
                "isEnabled": true,
                "excludedTypes": "Request"
            }
        }
    },
    "extensionBundle": {
        "id": "Microsoft.Azure.Functions.ExtensionBundle",
        "version": "[4.*, 5.0.0)"
    }
}
EOF

# Create requirements.txt
cat << 'EOF' > /tmp/func-app/requirements.txt
azure-functions
EOF

# Create function.json
cat << 'EOF' > /tmp/func-app/HttpTrigger/function.json
{
    "scriptFile": "__init__.py",
    "bindings": [
        {
            "authLevel": "anonymous",
            "type": "httpTrigger",
            "direction": "in",
            "name": "req",
            "methods": ["get", "post"]
        },
        {
            "type": "http",
            "direction": "out",
            "name": "$return"
        }
    ]
}
EOF

# Create the Python function
cat << 'EOF' > /tmp/func-app/HttpTrigger/__init__.py
import azure.functions as func
import json
from datetime import datetime

def main(req: func.HttpRequest) -> func.HttpResponse:
    name = req.params.get('name', 'World')

    response = {
        "message": f"Hello, {name}! Welcome to Azure Essentials!",
        "timestamp": datetime.utcnow().isoformat(),
        "course": "Azure Essentials"
    }

    return func.HttpResponse(
        json.dumps(response, indent=2),
        mimetype="application/json",
        status_code=200
    )
EOF
```

---

## Step 7: Deploy the Function

```bash
# Create a zip file
cd /tmp/func-app
zip -r ../func-app.zip .
cd -

# Deploy to Azure
az functionapp deployment source config-zip \
    --name "$FUNCTION_APP" \
    --resource-group "$RESOURCE_GROUP" \
    --src /tmp/func-app.zip
```

---

## Step 8: Test the Function

```bash
# Get the function URL and test it
FUNC_URL=$(az functionapp show \
    --name "$FUNCTION_APP" \
    --resource-group "$RESOURCE_GROUP" \
    --query defaultHostName \
    -o tsv)

echo "Testing function..."
curl "https://${FUNC_URL}/api/HttpTrigger?name=Azure"
```

---

## 📊 View Function App Info

```bash
# Show function app details
az functionapp show \
    --name "$FUNCTION_APP" \
    --resource-group "$RESOURCE_GROUP" \
    --query "{Name:name, State:state, Runtime:siteConfig.linuxFxVersion, URL:defaultHostName}" \
    -o table
```

```bash
# List functions in the app
az functionapp function list \
    --name "$FUNCTION_APP" \
    --resource-group "$RESOURCE_GROUP" \
    -o table
```

---

## 📚 Additional Commands

### View App Settings

```bash
az functionapp config appsettings list \
    --name "$FUNCTION_APP" \
    --resource-group "$RESOURCE_GROUP" \
    -o table
```

### View Logs

```bash
# Stream logs (Ctrl+C to stop)
az functionapp log deployment list \
    --name "$FUNCTION_APP" \
    --resource-group "$RESOURCE_GROUP"
```

### Restart Function App

```bash
az functionapp restart \
    --name "$FUNCTION_APP" \
    --resource-group "$RESOURCE_GROUP"
```

### Stop/Start Function App

```bash
# Stop
az functionapp stop \
    --name "$FUNCTION_APP" \
    --resource-group "$RESOURCE_GROUP"
```

```bash
# Start
az functionapp start \
    --name "$FUNCTION_APP" \
    --resource-group "$RESOURCE_GROUP"
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
rm -rf /tmp/func-app /tmp/func-app.zip
```

---

## 🔗 Quick Reference

| Command | Description |
|---------|-------------|
| `az functionapp create` | Create function app |
| `az functionapp show` | Show function app details |
| `az functionapp deployment source config-zip` | Deploy from zip |
| `az functionapp function list` | List functions |
| `az functionapp config appsettings set` | Configure settings |
| `az functionapp restart` | Restart the app |

---

## 🏗️ Hosting Plans Comparison

| Feature | Consumption | Premium | Dedicated |
|---------|-------------|---------|-----------|
| Scaling | Auto (0 to N) | Auto (1 to N) | Manual/Auto |
| Cold Start | Yes | Minimal | No |
| VNet | Limited | Yes | Yes |
| Max Timeout | 10 min | Unlimited | Unlimited |
| Billing | Per execution | Per second | Monthly |
