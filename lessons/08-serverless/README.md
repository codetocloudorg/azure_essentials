# Lesson 08: Serverless Services

> **Duration**: 45 minutes | **Day**: 2

## Overview

Serverless computing lets you run code without managing infrastructure. This lesson focuses on **Azure Functions** - the fastest way to build event-driven APIs and microservices.

## Learning Objectives

- Create an Azure Function App from the Portal
- Build and test an HTTP-triggered function
- Deploy code from the Cloud Shell
- Understand serverless pricing and scaling

---

## Quick Start (Portal + Cloud Shell)

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Create     │ ──▶ │   Add HTTP   │ ──▶ │    Test      │
│ Function App │     │   Function   │     │    URL       │
└──────────────┘     └──────────────┘     └──────────────┘
     Portal              Portal             Browser
```

---

## Key Concepts

### What is Serverless?

| Benefit | Description |
|---------|-------------|
| **No servers to manage** | Azure handles all infrastructure |
| **Auto-scaling** | Scales from zero to thousands of instances |
| **Pay per execution** | Only pay when your code runs |
| **Event-driven** | Triggered by HTTP, timers, queues, etc. |

### Common Trigger Types

| Trigger | Use Case | Example |
|---------|----------|---------|
| **HTTP** | REST APIs, webhooks | `GET /api/greeting?name=Azure` |
| **Timer** | Scheduled jobs | Run cleanup every hour |
| **Blob** | File processing | Resize uploaded images |
| **Queue** | Background tasks | Process orders |

---

## Hands-on Exercise: Create Your First Function

### Step 1: Create a Function App (Portal)

1. Go to the [Azure Portal](https://portal.azure.com)
2. Click **Create a resource** → Search **Function App**
3. Click **Create** and configure:

| Setting | Value |
|---------|-------|
| **Subscription** | Your subscription |
| **Resource Group** | `rg-azure-essentials-dev` (or create new) |
| **Function App name** | `func-hello-<yourname>` (must be unique) |
| **Runtime stack** | Python |
| **Version** | 3.11 |
| **Region** | Central US (or your preferred region) |
| **Operating System** | Linux |
| **Hosting plan** | Consumption (Serverless) |

4. Click **Review + create** → **Create**
5. Wait for deployment (about 1-2 minutes)

### Step 2: Create an HTTP Function (Portal)

1. Go to your new Function App
2. In the left menu, click **Functions** → **Create**
3. Select **HTTP trigger**
4. Configure:
   - **New Function**: `HttpTrigger`
   - **Authorization level**: Anonymous
5. Click **Create**

### Step 3: Edit the Function Code (Portal)

1. Click on your new function `HttpTrigger`
2. Click **Code + Test** in the left menu
3. Replace the code with:

```python
import azure.functions as func
import json
from datetime import datetime

def main(req: func.HttpRequest) -> func.HttpResponse:
    name = req.params.get('name', 'World')
    
    return func.HttpResponse(
        json.dumps({
            "message": f"Hello, {name}!",
            "timestamp": datetime.utcnow().isoformat(),
            "course": "Azure Essentials"
        }),
        mimetype="application/json"
    )
```

4. Click **Save**

### Step 4: Test Your Function

1. Click **Get function URL** at the top
2. Copy the URL and open in a browser
3. Add a name parameter: `?name=YourName`

**Example:**
```
https://func-hello-yourname.azurewebsites.net/api/HttpTrigger?name=Azure
```

**Response:**
```json
{
  "message": "Hello, Azure!",
  "timestamp": "2026-03-23T10:30:00.000000",
  "course": "Azure Essentials"
}
```

---

## Deploy from Cloud Shell (Optional)

If you want to deploy the sample function from code:

### Step 1: Clone the Repository

```bash
# Open the Cloud Shell (>_ icon in Azure Portal)
git clone https://github.com/codetocloudorg/azure_essentials.git
cd azure_essentials/lessons/08-serverless/src/sample-function
```

### Step 2: Deploy to Your Function App

```bash
# Find your Function App name
FUNC_APP=$(az functionapp list --query "[0].name" -o tsv)
echo "Deploying to: $FUNC_APP"

# Zip and deploy
zip -r function.zip . -x "*.git*" -x "__pycache__/*" -x ".venv/*"
az functionapp deployment source config-zip \
  --name $FUNC_APP \
  --resource-group rg-azure-essentials-dev \
  --src function.zip

# Test the function
echo "Test URL: https://$FUNC_APP.azurewebsites.net/api/HttpTrigger?name=Azure"
```

---

## Understand the Code

The sample function in `src/sample-function/` contains:

```
sample-function/
├── HttpTrigger/
│   ├── __init__.py      # Function code
│   └── function.json    # Trigger configuration
├── host.json            # App settings
└── requirements.txt     # Python dependencies
```

**function.json** - Defines the HTTP trigger:
```json
{
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
```

---

## View Logs and Monitor

1. In your Function App, click **Monitor** under Functions
2. Click on your function → **Invocations** tab
3. View logs for each execution
4. Click **Application Insights** for detailed metrics

---

## Cost Considerations

Azure Functions Consumption plan pricing:

| Resource | Free Tier | Additional Cost |
|----------|-----------|-----------------|
| **Executions** | 1 million/month | $0.20 per million |
| **Compute (GB-s)** | 400,000 GB-s/month | $0.000016/GB-s |

> **Tip**: For this lesson, you'll stay well within the free tier!

---

## Summary

In this lesson, you:

- ✅ Created a Function App from the Azure Portal
- ✅ Built an HTTP-triggered serverless function
- ✅ Tested your function with a browser
- ✅ Learned about serverless pricing and monitoring

---

## Cleanup (Optional)

To avoid charges, delete the Function App when done:

1. **Portal**: Go to your Function App → **Delete**
2. **CLI**: `az functionapp delete --name <func-name> --resource-group rg-azure-essentials-dev`

---

## Next Steps

Continue to [Lesson 09: Database Services](../09-database-services/README.md) to work with Azure Cosmos DB.

---

## Additional Resources

- [Azure Functions Quick Start](https://learn.microsoft.com/azure/azure-functions/create-first-function-vs-code-python)
- [HTTP Trigger Reference](https://learn.microsoft.com/azure/azure-functions/functions-bindings-http-webhook)
- [Functions Pricing](https://azure.microsoft.com/pricing/details/functions/)
