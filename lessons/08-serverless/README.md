# Lesson 08: Serverless Services

> **Duration**: 45 minutes | **Day**: 2

## Overview

Serverless computing lets you run code without managing infrastructure. This lesson focuses on **Azure Functions** - the fastest way to build event-driven APIs and microservices.

## Learning Objectives

- Deploy a Python Azure Function from Cloud Shell
- Understand how serverless functions work
- Edit function code in the Azure Portal
- Test your function via browser

---

## Quick Start

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Deploy     │ ──▶ │    Edit      │ ──▶ │    Test      │
│  via azd up  │     │  in Portal   │     │   in Browser │
└──────────────┘     └──────────────┘     └──────────────┘
   Local CLI           Optional            URL + ?name=
```

**Prerequisites**: Run `azd up` with `LESSON_NUMBER=08` to create the Function App infrastructure.

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
| **HTTP** | REST APIs, webhooks | `GET /api/HttpTrigger?name=Azure` |
| **Timer** | Scheduled jobs | Run cleanup every hour |
| **Blob** | File processing | Resize uploaded images |
| **Queue** | Background tasks | Process orders |

---

## Hands-on Exercise: Deploy Your Function

### Step 1: Deploy Function Code (Cloud Shell)

Open **Cloud Shell** (click the `>_` icon in Azure Portal) and run:

```bash
# Clone the repository
git clone https://github.com/codetocloudorg/azure_essentials.git
cd azure_essentials/lessons/08-serverless/src/sample-function

# Auto-discover your Function App and Resource Group
FUNC_APP=$(az functionapp list --query "[0].name" -o tsv)
RG=$(az functionapp list --query "[0].resourceGroup" -o tsv)
echo "Deploying to: $FUNC_APP in $RG"

# Configure Python runtime
az functionapp config appsettings set \
  --name $FUNC_APP \
  --resource-group $RG \
  --settings FUNCTIONS_WORKER_RUNTIME=python

# Zip and deploy
zip -r function.zip . -x "*.git*" -x "__pycache__/*"
az functionapp deployment source config-zip \
  --name $FUNC_APP \
  --resource-group $RG \
  --src function.zip

# Get the test URL
echo ""
echo "✅ Deployment complete!"
echo "Test URL: https://$FUNC_APP.azurewebsites.net/api/HttpTrigger?name=Azure"
```

### Step 2: Test Your Function

Open the URL in your browser:
```
https://<your-func-app>.azurewebsites.net/api/HttpTrigger?name=YourName
```

**Expected Response:**
```json
{
  "message": "Hello, YourName! Welcome to Azure Functions.",
  "timestamp": "2026-03-23T10:30:00.000000",
  "function": "HttpTrigger",
  "course": "Azure Essentials"
}
```

---

## Understanding the Code

### Project Structure

```
sample-function/
├── HttpTrigger/
│   ├── __init__.py      # Function code (Python)
│   └── function.json    # Trigger configuration
├── host.json            # App-level settings
└── requirements.txt     # Python dependencies
```

### The Function Code (`__init__.py`)

```python
import azure.functions as func
import json
from datetime import datetime

def main(req: func.HttpRequest) -> func.HttpResponse:
    """
    HTTP trigger function that returns a greeting.
    """
    # Get 'name' from query string (?name=Azure) or request body
    name = req.params.get('name')
    
    if not name:
        try:
            req_body = req.get_json()
            name = req_body.get('name')
        except ValueError:
            pass

    # Build the response message
    if name:
        message = f"Hello, {name}! Welcome to Azure Functions."
    else:
        message = "Hello! Pass a name in the query string or request body."

    # Return JSON response
    response_data = {
        "message": message,
        "timestamp": datetime.utcnow().isoformat(),
        "function": "HttpTrigger",
        "course": "Azure Essentials"
    }

    return func.HttpResponse(
        json.dumps(response_data, indent=2),
        mimetype="application/json",
        status_code=200
    )
```

**Code Breakdown:**

| Line | What it does |
|------|--------------|
| `req: func.HttpRequest` | The incoming HTTP request object |
| `req.params.get('name')` | Gets `?name=value` from the URL |
| `req.get_json()` | Gets JSON body for POST requests |
| `func.HttpResponse(...)` | Returns the HTTP response |
| `mimetype="application/json"` | Tells browsers this is JSON |

### The Trigger Configuration (`function.json`)

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

**What each setting means:**

| Setting | Value | Description |
|---------|-------|-------------|
| `authLevel` | `anonymous` | No API key required |
| `type` | `httpTrigger` | Triggered by HTTP requests |
| `methods` | `["get", "post"]` | Accepts GET and POST |
| `direction` | `in` / `out` | Input binding / Output binding |

---

## Edit Code in the Portal

After deployment, you can edit your function directly in the Azure Portal:

1. Go to your **Function App** in the Portal
2. Click **Functions** → Click on **HttpTrigger**
3. Click **Code + Test** in the left menu
4. Edit the code in the browser editor
5. Click **Save**
6. Click **Test/Run** to test your changes

> **Tip**: Portal editing is great for quick changes. For larger projects, use VS Code with the Azure Functions extension.

### Try This: Modify the Response

Change the message in the Portal:

```python
message = f"Hello, {name}! You're learning Azure Functions 🎉"
```

Click **Save** and test your URL again!

---

## View Logs and Monitor

1. In your Function App, click **Functions** → **HttpTrigger**
2. Click **Monitor** in the left menu
3. View the **Invocations** tab to see execution history
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

## Troubleshooting

### Error: "WorkerConfig for runtime: python not found"

The Function App isn't configured for Python.

**Fix:**
```bash
FUNC_APP=$(az functionapp list --query "[0].name" -o tsv)
RG=$(az functionapp list --query "[0].resourceGroup" -o tsv)
az functionapp config appsettings set \
  --name $FUNC_APP \
  --resource-group $RG \
  --settings FUNCTIONS_WORKER_RUNTIME=python
```

### Function returns 404 Not Found

1. **Verify function name**: Use `HttpTrigger` (capital H and T)
2. **Check the URL format**: `https://<app>.azurewebsites.net/api/HttpTrigger`
3. **Restart the app**: Portal → Overview → Restart

### CORS error when testing from Portal

```bash
FUNC_APP=$(az functionapp list --query "[0].name" -o tsv)
RG=$(az functionapp list --query "[0].resourceGroup" -o tsv)
az functionapp cors add \
  --name $FUNC_APP \
  --resource-group $RG \
  --allowed-origins https://portal.azure.com
```

---

## Summary

In this lesson, you:

- ✅ Deployed a Python function from Cloud Shell
- ✅ Understood the function code structure
- ✅ Learned how triggers and bindings work
- ✅ Edited code directly in the Azure Portal
- ✅ Tested your serverless API in a browser

---

## Cleanup (Optional)

Delete the Function App when done:

```bash
FUNC_APP=$(az functionapp list --query "[0].name" -o tsv)
RG=$(az functionapp list --query "[0].resourceGroup" -o tsv)
az functionapp delete --name $FUNC_APP --resource-group $RG
```

---

## Next Steps

Continue to [Lesson 09: Database Services](../09-database-services/README.md) to work with Azure Cosmos DB.

---

## Additional Resources

- [Azure Functions Python Developer Guide](https://learn.microsoft.com/azure/azure-functions/functions-reference-python)
- [HTTP Trigger Reference](https://learn.microsoft.com/azure/azure-functions/functions-bindings-http-webhook)
- [Functions Pricing](https://azure.microsoft.com/pricing/details/functions/)
