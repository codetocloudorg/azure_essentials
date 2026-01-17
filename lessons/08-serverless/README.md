# Lesson 08: Serverless Services

> **Duration**: 60 minutes | **Day**: 2

## Overview

Serverless computing lets you run code without managing infrastructure. This lesson covers Azure Functions for event-driven compute and Logic Apps for workflow automation.

## Learning Objectives

By the end of this lesson, you will be able to:

- Explain serverless computing concepts and benefits
- Create and deploy Azure Functions with various triggers
- Configure bindings for input and output data
- Build automated workflows with Logic Apps
- Choose between Functions and Logic Apps for different scenarios

---

## Key Concepts

### What is Serverless?

Serverless computing provides:

| Benefit | Description |
|---------|-------------|
| **No infrastructure management** | Focus on code, not servers |
| **Automatic scaling** | Scale from zero to thousands |
| **Pay per execution** | Only pay when code runs |
| **Event-driven** | Respond to triggers automatically |

### Azure Functions Triggers and Bindings

| Trigger Type | Description | Example Use Case |
|--------------|-------------|------------------|
| **HTTP** | REST API requests | Web APIs, webhooks |
| **Timer** | Scheduled execution | Cleanup jobs, reports |
| **Blob** | Storage changes | Image processing |
| **Queue** | Message processing | Order processing |
| **Cosmos DB** | Database changes | Data synchronisation |
| **Event Hub** | Stream processing | IoT data, telemetry |

### Functions vs Logic Apps

| Aspect | Azure Functions | Logic Apps |
|--------|-----------------|------------|
| **Primary use** | Code-first | Designer-first |
| **Development** | Write code | Visual workflow |
| **Integrations** | Custom connectors | 400+ built-in connectors |
| **Best for** | Complex logic | Integration workflows |
| **Pricing** | Per execution | Per action |

---

## Hands-on Exercises

### Exercise 8.1: Create an Azure Function (HTTP Trigger)

**Objective**: Build and deploy a simple HTTP-triggered function.

#### Create the Function App in Azure

```bash
# Variables
RESOURCE_GROUP="rg-azure-essentials-dev"
LOCATION="uksouth"
STORAGE_NAME="stfunc$(openssl rand -hex 4)"
FUNCTION_APP="func-essentials-$(openssl rand -hex 4)"

# Create storage account for the function
az storage account create \
  --name $STORAGE_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS

# Create the Function App
az functionapp create \
  --name $FUNCTION_APP \
  --resource-group $RESOURCE_GROUP \
  --storage-account $STORAGE_NAME \
  --consumption-plan-location $LOCATION \
  --runtime python \
  --runtime-version 3.11 \
  --functions-version 4 \
  --os-type Linux

echo "Function App URL: https://$FUNCTION_APP.azurewebsites.net"
```

#### Create the Function Code Locally

```bash
# Create function project directory
mkdir -p sample-function && cd sample-function

# Create the function code
mkdir -p HttpTrigger

cat > HttpTrigger/function.json << 'EOF'
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
EOF

cat > HttpTrigger/__init__.py << 'EOF'
import azure.functions as func
import json
from datetime import datetime

def main(req: func.HttpRequest) -> func.HttpResponse:
    """HTTP trigger function that returns a greeting."""
    
    # Get name from query string or request body
    name = req.params.get('name')
    if not name:
        try:
            req_body = req.get_json()
            name = req_body.get('name')
        except ValueError:
            pass
    
    if name:
        message = f"Hello, {name}! Welcome to Azure Functions."
    else:
        message = "Hello! Pass a name in the query string or request body."
    
    response_data = {
        "message": message,
        "timestamp": datetime.utcnow().isoformat(),
        "function": "HttpTrigger"
    }
    
    return func.HttpResponse(
        json.dumps(response_data),
        mimetype="application/json",
        status_code=200
    )
EOF

# Create requirements.txt
cat > requirements.txt << 'EOF'
azure-functions
EOF

# Create host.json
cat > host.json << 'EOF'
{
  "version": "2.0",
  "logging": {
    "applicationInsights": {
      "samplingSettings": {
        "isEnabled": true
      }
    }
  },
  "extensionBundle": {
    "id": "Microsoft.Azure.Functions.ExtensionBundle",
    "version": "[4.*, 5.0.0)"
  }
}
EOF

# Create local.settings.json
cat > local.settings.json << 'EOF'
{
  "IsEncrypted": false,
  "Values": {
    "FUNCTIONS_WORKER_RUNTIME": "python",
    "AzureWebJobsStorage": ""
  }
}
EOF
```

#### Deploy to Azure

```bash
# Zip the function for deployment
zip -r function.zip . -x "*.git*"

# Deploy to Azure
az functionapp deployment source config-zip \
  --name $FUNCTION_APP \
  --resource-group $RESOURCE_GROUP \
  --src function.zip

# Test the function
curl "https://$FUNCTION_APP.azurewebsites.net/api/HttpTrigger?name=Azure"

cd ..
```

### Exercise 8.2: Create a Timer-Triggered Function

**Objective**: Create a function that runs on a schedule.

```bash
# Add a timer trigger function
cd sample-function
mkdir -p TimerTrigger

cat > TimerTrigger/function.json << 'EOF'
{
  "bindings": [
    {
      "name": "timer",
      "type": "timerTrigger",
      "direction": "in",
      "schedule": "0 */5 * * * *"
    }
  ]
}
EOF

cat > TimerTrigger/__init__.py << 'EOF'
import azure.functions as func
import logging
from datetime import datetime

def main(timer: func.TimerRequest) -> None:
    """Timer trigger function that runs every 5 minutes."""
    
    if timer.past_due:
        logging.info('Timer is past due!')
    
    logging.info(f'Timer trigger executed at: {datetime.utcnow().isoformat()}')
    
    # Add your scheduled task logic here
    # Examples: cleanup, report generation, data sync
EOF

# Redeploy
zip -r function.zip . -x "*.git*"
az functionapp deployment source config-zip \
  --name $FUNCTION_APP \
  --resource-group $RESOURCE_GROUP \
  --src function.zip

cd ..
```

### Exercise 8.3: Create a Logic App Workflow

**Objective**: Build a simple automated workflow using Logic Apps.

#### Using Azure CLI

```bash
# Create a Logic App
LOGIC_APP="logic-essentials-$(openssl rand -hex 4)"

az logic workflow create \
  --name $LOGIC_APP \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --definition '{
    "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
    "contentVersion": "1.0.0.0",
    "triggers": {
      "manual": {
        "type": "Request",
        "kind": "Http",
        "inputs": {
          "schema": {
            "type": "object",
            "properties": {
              "name": {"type": "string"},
              "email": {"type": "string"}
            }
          }
        }
      }
    },
    "actions": {
      "Response": {
        "type": "Response",
        "kind": "Http",
        "inputs": {
          "statusCode": 200,
          "body": {
            "message": "Workflow triggered successfully",
            "receivedName": "@triggerBody()?['\''name'\'']"
          }
        },
        "runAfter": {}
      }
    }
  }'

# Get the callback URL
az logic workflow show \
  --name $LOGIC_APP \
  --resource-group $RESOURCE_GROUP \
  --query "accessEndpoint" \
  --output tsv
```

#### Using the Azure Portal (Recommended for Complex Workflows)

1. Navigate to **Logic Apps** in the Azure Portal
2. Select **Create**
3. Choose **Consumption** plan type
4. Configure:
   - **Subscription**: Your subscription
   - **Resource group**: `rg-azure-essentials-dev`
   - **Logic app name**: `logic-workflow-demo`
   - **Region**: Your region
5. Select **Review + create**, then **Create**
6. Open the Logic App Designer
7. Choose **When an HTTP request is received** trigger
8. Add actions from the connector library

---

## Function Bindings Example

Bindings connect functions to other services without code:

```python
# function.json with queue output binding
{
  "bindings": [
    {
      "type": "httpTrigger",
      "direction": "in",
      "name": "req"
    },
    {
      "type": "http",
      "direction": "out",
      "name": "$return"
    },
    {
      "type": "queue",
      "direction": "out",
      "name": "msg",
      "queueName": "outqueue",
      "connection": "AzureWebJobsStorage"
    }
  ]
}
```

```python
# __init__.py
import azure.functions as func

def main(req: func.HttpRequest, msg: func.Out[str]) -> func.HttpResponse:
    name = req.params.get('name', 'Anonymous')
    
    # Write to queue using output binding
    msg.set(f"New request from: {name}")
    
    return func.HttpResponse(f"Hello, {name}!")
```

---

## Key Commands Reference

```bash
# Azure Functions
az functionapp create --name <n> --runtime python
az functionapp deployment source config-zip --src <zip>
az functionapp function show --name <app> --function-name <func>
func start  # Local development

# Logic Apps
az logic workflow create --name <n> --definition <json>
az logic workflow show --name <n>
az logic workflow start --name <n>
```

---

## Summary

In this lesson, you learned:

- ✅ Serverless computing concepts and benefits
- ✅ Creating Azure Functions with HTTP and timer triggers
- ✅ Understanding bindings for input/output data
- ✅ Building workflows with Logic Apps
- ✅ Choosing between Functions and Logic Apps

---

## Next Steps

Continue to [Lesson 09: Database and Data Services](../09-database-services/README.md) to explore Azure data platforms.

---

## Additional Resources

- [Azure Functions Documentation](https://learn.microsoft.com/azure/azure-functions/)
- [Logic Apps Documentation](https://learn.microsoft.com/azure/logic-apps/)
- [Serverless Best Practices](https://learn.microsoft.com/azure/azure-functions/functions-best-practices)
