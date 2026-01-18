# ☁️ Cloud Quote API

> **Code to Cloud** | Azure Essentials - Lesson 05 Sample Application

A simple .NET Web API that serves inspirational quotes about cloud computing. Deploy to Azure App Service to see your first cloud-native application in action!

---

## 🎯 What This App Does

- Serves random cloud computing quotes via REST API
- Demonstrates Azure App Service deployment
- Includes health check endpoint for monitoring
- Shows environment-aware configuration

---

## 🚀 Quick Start

### Run Locally

```bash
cd lessons/05-compute-windows/src/cloud-quote-api
dotnet run
```

Visit: http://localhost:5000/api/quotes/random

### Deploy to Azure

```bash
# Create App Service and deploy
az webapp up \
    --name "cloudquote-$(openssl rand -hex 4)" \
    --resource-group "rg-essentials-windows" \
    --runtime "DOTNET|8.0" \
    --sku F1
```

---

## 📡 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Welcome message |
| `/api/quotes` | GET | List all quotes |
| `/api/quotes/random` | GET | Get a random quote |
| `/api/quotes/{id}` | GET | Get a specific quote |
| `/health` | GET | Health check |

---

## 📦 Sample Response

```json
{
    "id": 3,
    "text": "The cloud is not about the cloud. It's about what the cloud enables.",
    "author": "Satya Nadella",
    "category": "vision",
    "timestamp": "2026-01-18T10:30:00Z"
}
```

---

## 🏗️ Project Structure

```
cloud-quote-api/
├── Program.cs           # Application entry point
├── CloudQuoteApi.csproj # Project configuration
├── appsettings.json     # Configuration
└── README.md            # This file
```

---

## 🎓 Learning Objectives

By deploying this app, you'll learn:

1. How to create an Azure App Service
2. How to deploy .NET applications to the cloud
3. How to configure environment variables
4. How to view application logs

---

<p align="center">
  <strong>Code to Cloud</strong> | Building the future, one deployment at a time
</p>
