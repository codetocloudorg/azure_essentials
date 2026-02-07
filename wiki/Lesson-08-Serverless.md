# Lesson 08: Serverless Functions

> **Time:** 30 minutes | **Difficulty:** Medium | **Cost:** ~$0 (free tier)

## 🎯 What You'll Build

By the end of this lesson, you'll have:
- Created an Azure Function App
- Deployed a serverless function
- Triggered it via HTTP request
- Understood when to use serverless

---

## ☁️ What Is Serverless?

"Serverless" doesn't mean no servers—it means **you don't manage them**.

### Traditional vs Serverless

| Aspect | Traditional VM | Serverless |
|--------|---------------|------------|
| **You manage** | OS, runtime, scaling | Just your code |
| **Billing** | Pay for uptime | Pay per execution |
| **Scaling** | Manual or autoscale rules | Automatic (instant) |
| **Idle cost** | Still paying | $0 when not running |

### When to Use Serverless

✅ **Good for:**
- Event-driven processing (file uploads, webhooks)
- APIs with variable traffic
- Scheduled tasks (cron jobs)
- Prototypes and MVPs

❌ **Not ideal for:**
- Long-running processes (>10 min)
- Applications needing persistent connections
- Consistent high-volume workloads

---

## 🏗️ Create a Function App

### Step 1: Set Up Resources

```bash
# Variables
RG_NAME="rg-serverless-lesson"
LOCATION="centralus"
STORAGE_NAME="stfuncstorage$RANDOM"  # Must be globally unique
FUNC_APP_NAME="func-hello-$RANDOM"    # Must be globally unique

# Create resource group
az group create --name $RG_NAME --location $LOCATION

# Create storage account (required for Functions)
az storage account create \
  --name $STORAGE_NAME \
  --resource-group $RG_NAME \
  --location $LOCATION \
  --sku Standard_LRS
```

### Step 2: Create the Function App

```bash
az functionapp create \
  --resource-group $RG_NAME \
  --name $FUNC_APP_NAME \
  --storage-account $STORAGE_NAME \
  --consumption-plan-location $LOCATION \
  --runtime python \
  --runtime-version 3.11 \
  --functions-version 4 \
  --os-type Linux
```

**What this creates:**
- Function App container
- Consumption plan (pay-per-execution)
- Python 3.11 runtime

### Step 3: Get the URL

```bash
echo "Your Function App URL: https://$FUNC_APP_NAME.azurewebsites.net"
```

---

## 💻 Create Your First Function

### Option A: Using Azure Portal

1. Go to [portal.azure.com](https://portal.azure.com)
2. Find your Function App
3. Click **"Functions"** → **"+ Create"**
4. Select **"HTTP trigger"**
5. Name it `hello`
6. Set Authorization level to **"Anonymous"** (for testing)
7. Click **"Create"**

### Option B: Using Azure Functions Core Tools

Install the tools first:
```bash
# Mac
brew install azure-functions-core-tools@4

# Or using npm
npm install -g azure-functions-core-tools@4
```

Create a local project:
```bash
# Create project folder
mkdir my-function && cd my-function

# Initialize (Python)
func init --worker-runtime python

# Create HTTP trigger function
func new --name hello --template "HTTP trigger"
```

This creates:
```
my-function/
├── host.json
├── local.settings.json
├── requirements.txt
└── hello/
    ├── __init__.py
    └── function.json
```

---

## 📝 Understand the Code

Open `hello/__init__.py`:

```python
import azure.functions as func
import logging

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    # Get 'name' from query string or body
    name = req.params.get('name')
    if not name:
        try:
            req_body = req.get_json()
            name = req_body.get('name')
        except ValueError:
            pass

    if name:
        return func.HttpResponse(f"Hello, {name}!")
    else:
        return func.HttpResponse(
            "Pass a name in the query string or request body",
            status_code=400
        )
```

**What it does:**
1. Receives HTTP request
2. Looks for `name` parameter
3. Returns personalized greeting

---

## 🧪 Test Locally

```bash
# Start local runtime
func start
```

Output:
```
Functions:
    hello: [GET,POST] http://localhost:7071/api/hello
```

Test it:
```bash
# In another terminal
curl "http://localhost:7071/api/hello?name=World"
```

Response:
```
Hello, World!
```

---

## 🚀 Deploy to Azure

```bash
# Deploy from your project folder
func azure functionapp publish $FUNC_APP_NAME
```

Once deployed, test it:
```bash
curl "https://$FUNC_APP_NAME.azurewebsites.net/api/hello?name=Azure"
```

---

## 🔑 Function Triggers

Functions can be triggered by many events:

| Trigger | Use Case | Example |
|---------|----------|---------|
| **HTTP** | REST APIs, webhooks | `GET /api/users` |
| **Timer** | Scheduled jobs | Run every 5 minutes |
| **Blob** | File processing | Process uploaded images |
| **Queue** | Background jobs | Send emails async |
| **Cosmos DB** | Data changes | Update search index |
| **Event Hub** | Streaming data | IoT telemetry |

### Timer Trigger Example

```python
# Run every 5 minutes
import azure.functions as func
import logging

def main(timer: func.TimerRequest) -> None:
    logging.info('Timer trigger executed!')
    # Your scheduled task here
```

`function.json`:
```json
{
  "scriptFile": "__init__.py",
  "bindings": [
    {
      "name": "timer",
      "type": "timerTrigger",
      "direction": "in",
      "schedule": "0 */5 * * * *"
    }
  ]
}
```

---

## 📊 Monitor Your Function

### View Logs

```bash
func azure functionapp logstream $FUNC_APP_NAME
```

### In the Portal

1. Go to your Function App
2. Click **"Monitor"** under your function
3. See execution history and logs

### Application Insights

For production, enable Application Insights for:
- Detailed telemetry
- Performance monitoring
- Error tracking

---

## 💰 Understanding Costs

### Consumption Plan (Pay-per-use)

| Metric | Free Grant | Cost After |
|--------|------------|------------|
| Executions | 1M/month free | $0.20 per million |
| Duration | 400K GB-s free | $0.000016/GB-s |

**Example:** A function that runs 100ms with 256MB RAM:
- 1 million executions = ~$0 (within free tier)
- 10 million executions ≈ $1.80/month

---

## 🧹 Clean Up

```bash
az group delete --name $RG_NAME --yes
```

---

## ⚠️ Common Mistakes

| Mistake | Fix |
|---------|-----|
| Function times out | Check timeout settings (default: 5 min) |
| Cold start too slow | Use Premium plan for warm instances |
| Can't reach function | Check auth level (Anonymous for testing) |
| Module not found | Add to requirements.txt and redeploy |

---

## ✅ What You Learned

- ☁️ What serverless means (pay-per-execution, auto-scaling)
- 🏗️ How to create a Function App
- 💻 How to write and deploy functions
- 🔑 Different trigger types (HTTP, Timer, Blob, etc.)
- 📊 How to monitor your functions

---

## ➡️ Next Steps

Let's add a database to store data!

👉 **[Lesson 09: Database Services](Lesson-09-Database-Services)**

---

*Questions? Join our [Discord](https://discord.gg/vwfwq2EpXJ) community!*
