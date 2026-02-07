# 📚 Azure Essentials - Lesson Index

> **Code to Cloud** | Your guide to Azure mastery

---

## 🚀 Before You Start

### Fastest Option: GitHub Codespaces

[![Open in GitHub Codespaces](https://img.shields.io/badge/Open%20in-Codespaces-black?style=for-the-badge&logo=github)](https://codespaces.new/codetocloudorg/azure_essentials)

All tools pre-installed, ready to go in your browser!

> 💡 [Learn more about Dev Containers](https://github.com/codetocloudorg/platform-engineering/blob/main/docs/codespaces.md)

### Local Setup

1. **Run Preflight Checks** — Validate your environment is ready:
   - macOS/Linux: `./scripts/bash/validate-env.sh`
   - Windows: `.\scripts\powershell\validate-env.ps1`

2. **📜 [Scripts Guide](../SCRIPTS.md)** — How to run scripts, deploy lessons, and troubleshoot

---

## 🗓️ Day 1: Foundations

| #   | Lesson                                                               | Duration  | Description                                         | Resources         |
| --- | -------------------------------------------------------------------- | --------- | --------------------------------------------------- | ----------------- |
| 00  | [Prerequisites & Setup](00-prerequisites/README.md)                  | 15-30 min | Set up your machine for the course                  | None              |
| 01  | [Introduction to Azure](01-introduction/README.md)                   | 55 min    | Cloud concepts, service models, Portal & CLI basics | None              |
| 02  | [Getting Started](02-getting-started/README.md)                      | 20 min    | Accounts, subscriptions, tenants, resource groups   | Management Groups |
| 03  | [Storage Services](03-storage-services/README.md)                    | 55 min    | Blobs, files, queues, tables, redundancy options    | Storage Account   |
| 04  | [Networking](04-networking/README.md)                                | 35 min    | Virtual networks, subnets, NSGs, load balancers     | VNet, NSG         |
| 05  | [Compute: Windows](05-compute-windows/README.md)                     | 30 min    | Windows VMs, availability, App Service              | VM, App Service   |
| 06  | [Compute: Linux & Kubernetes](06-compute-linux-kubernetes/README.md) | 25 min    | Linux workloads, MicroK8s fundamentals              | Ubuntu VM         |
| 07  | [Container Services](07-container-services/README.md)                | 25 min    | Azure Container Registry, container deployment      | ACR               |

---

## 🗓️ Day 2: Advanced Services

| #   | Lesson                                                  | Duration | Description                                              | Resources    |
| --- | ------------------------------------------------------- | -------- | -------------------------------------------------------- | ------------ |
| 08  | [Serverless Services](08-serverless/README.md)          | 60 min   | Azure Functions, triggers, bindings, Logic Apps          | Function App |
| 09  | [Database Services](09-database-services/README.md)     | 60 min   | Azure SQL, Cosmos DB, Microsoft Fabric intro             | Cosmos DB    |
| 10  | [Billing & Cost](10-billing-cost/README.md)             | 20 min   | Cost management, budgets, resource tagging               | None         |
| 11  | [Azure AI Foundry](11-ai-foundry/README.md)             | 45 min   | AI workspaces, model catalog, chatbot development        | AI Hub       |
| 12  | [Architecture Design](12-architecture-design/README.md) | 45 min   | Collaborative design session, Well-Architected Framework | None         |

---

## 🚀 Quick Start

### Option 1: Follow Along in Order

Start with [Lesson 00: Prerequisites](00-prerequisites/README.md) and work through each lesson sequentially.

### Option 2: Jump to a Specific Topic

Use the table above to navigate directly to the lesson you need.

### Option 3: Deploy All Resources at Once

```bash
# Deploy infrastructure for all lessons
azd up
```

### Option 4: Deploy a Single Lesson

```bash
# Deploy only lesson 03 resources
azd env set LESSON_NUMBER 03
azd up
```

---

## 📁 Sample Applications

Several lessons include sample code you can deploy:

| Lesson                           | Sample App      | Description                              |
| -------------------------------- | --------------- | ---------------------------------------- |
| [05](05-compute-windows/src/)    | Cloud Quote API | .NET API with inspirational cloud quotes |
| [07](07-container-services/src/) | Cloud Dashboard | Containerized status dashboard           |
| [08](08-serverless/src/)         | Sample Function | Python HTTP trigger function             |
| [09](09-database-services/src/)  | Cosmos Test App | Python Cosmos DB CRUD operations         |
| [11](11-ai-foundry/src/)         | Simple Chatbot  | Python Azure OpenAI chatbot              |

---

## 💰 Free Tier Compatibility

| Lesson | Free Tier | Notes                              |
| ------ | --------- | ---------------------------------- |
| 01-04  | ✅        | Fully free                         |
| 05     | ✅        | Use F1 App Service SKU             |
| 06     | ✅        | Local MicroK8s only                |
| 07     | ⚠️        | ACR Basic ~$5/month                |
| 08     | ✅        | Consumption plan is free           |
| 09     | ⚠️        | Cosmos DB Serverless (pay-per-use) |
| 10     | ✅        | Portal demo only                   |
| 11     | ⚠️        | AI services have costs             |
| 12     | ✅        | Design workshop only               |

---

## 🧹 Cleanup

Always clean up resources when finished to avoid charges:

```bash
# Remove all deployed resources
azd down --force --purge
```

---

## 🔗 Additional Resources

- [Azure CLI Commands (Copy-Paste)](../scripts/azure-cli/commands/README.md)
- [Interactive Deployment Scripts](../scripts/bash/deploy.sh)
- [Infrastructure Modules](../infra/modules/)

---

## 💬 Community

Join the Code to Cloud community for help and discussions:

[![Website](https://img.shields.io/badge/Website-codetocloud.io-00A4EF?logo=microsoft-edge&logoColor=white)](https://www.codetocloud.io)
[![Discord](https://img.shields.io/badge/Discord-Join%20Us-5865F2?logo=discord&logoColor=white)](https://discord.gg/vwfwq2EpXJ)
[![Podcast](https://img.shields.io/badge/Podcast-Spotify-1DB954?logo=spotify&logoColor=white)](https://open.spotify.com/show/1iOZfFVamUk7CJPOvtU00v)

---

<p align="center">
  <strong>Code to Cloud Inc.</strong> | Azure Essentials Training<br/>
  <sub>© 2024-2026 Code to Cloud Inc. | <a href="../LICENSE">MIT License</a></sub>
</p>
