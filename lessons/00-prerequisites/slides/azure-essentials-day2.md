---
marp: true
theme: default
paginate: true
header: "Azure Essentials | Code to Cloud"
footer: "Day 2 — Advanced Services"
style: |
  section {
    font-size: 28px;
  }
  h1 {
    color: #0078D4;
  }
  h2 {
    color: #106EBE;
  }
  table {
    font-size: 22px;
  }
---

# Azure Essentials
## Day 2 — Advanced Services

**Code to Cloud**

![bg right:40% 80%](https://upload.wikimedia.org/wikipedia/commons/f/fa/Microsoft_Azure.svg)

---

# Day 2 Agenda

| Module | Topic | Duration |
|--------|-------|----------|
| 8 | Serverless Services | 60 min |
| 9 | Database & Data Services | 60 min |
| 10 | Billing & Cost Optimization | 20 min |
| 11 | Azure AI Foundry | 45 min |
| 12 | Architecture Design | 45 min |
| | Wrap-up & Q&A | 10 min |

---

<!-- _class: lead -->

# Module 8
## Serverless Services

---

# What is Serverless?

| Benefit | Description |
|---------|-------------|
| **No infrastructure** | Focus on code, not servers |
| **Automatic scaling** | Scale from zero to thousands |
| **Pay per execution** | Only pay when code runs |
| **Event-driven** | Respond to triggers automatically |

> 📚 [Serverless Computing](https://learn.microsoft.com/azure/architecture/reference-architectures/serverless/web-app)

---

# Azure Functions Triggers

| Trigger | Description | Use Case |
|---------|-------------|----------|
| **HTTP** | REST API requests | APIs, webhooks |
| **Timer** | Scheduled execution | Cleanup jobs |
| **Blob** | Storage changes | Image processing |
| **Queue** | Message processing | Order processing |
| **Cosmos DB** | Database changes | Data sync |
| **Event Hub** | Stream processing | IoT, telemetry |

> 📚 [Triggers & Bindings](https://learn.microsoft.com/azure/azure-functions/functions-triggers-bindings)

---

# Functions vs Logic Apps

| Aspect | Azure Functions | Logic Apps |
|--------|-----------------|------------|
| **Development** | Code-first | Designer-first |
| **Complexity** | Complex logic | Integration workflows |
| **Connectors** | Custom | 400+ built-in |
| **Pricing** | Per execution | Per action |
| **Best for** | Custom business logic | Connect SaaS services |

> 📚 [Compare Options](https://learn.microsoft.com/azure/azure-functions/functions-compare-logic-apps-ms-flow-webjobs)

---

# Hosting Plans

| Plan | Scaling | Cold Start | Max Timeout |
|------|---------|------------|-------------|
| **Consumption** | Auto (0→∞) | Yes | 10 min |
| **Premium** | Pre-warmed | No | Unlimited |
| **Dedicated** | Manual | No | Unlimited |

> 📚 [Hosting Options](https://learn.microsoft.com/azure/azure-functions/functions-scale)

---

# 🖐️ Hands-on: Serverless

**Exercise 8.1** — Create Function App
- Create Function App with Consumption plan

**Exercise 8.2** — HTTP Trigger Function
- Create HTTP-triggered function
- Test with query parameters

📂 **See:** `lessons/08-serverless/README.md`

---

# ✅ Module 8 Summary

- Serverless = no infrastructure to manage
- Functions: code-first, event-driven compute
- Logic Apps: visual designer for integrations
- Consumption plan: pay only when code runs

---

<!-- _class: lead -->

# Module 9
## Database & Data Services

---

# Azure Database Options

| Service | Type | Best For |
|---------|------|----------|
| **Azure SQL** | Relational | Enterprise, SQL Server |
| **PostgreSQL Flexible** | Relational | Open-source PostgreSQL |
| **MySQL Flexible** | Relational | Open-source MySQL |
| **Cosmos DB** | NoSQL | Global distribution |
| **Table Storage** | NoSQL | Simple key-value |

> 📚 [Choose Database](https://learn.microsoft.com/azure/architecture/guide/technology-choices/data-store-decision-tree)

---

# Cosmos DB APIs

| API | Data Model | Use Case |
|-----|------------|----------|
| **NoSQL** | Document (JSON) | Modern apps, flexible schema |
| **MongoDB** | Document | MongoDB compatibility |
| **PostgreSQL** | Relational | Distributed PostgreSQL |
| **Cassandra** | Wide-column | High-scale writes |
| **Gremlin** | Graph | Relationship data |

> 📚 [Cosmos DB APIs](https://learn.microsoft.com/azure/cosmos-db/choose-api)

---

# Cosmos DB Consistency Levels

| Level | Consistency | Latency | Use Case |
|-------|-------------|---------|----------|
| **Strong** | Highest | Highest | Financial transactions |
| **Bounded Staleness** | High | Medium | Inventory systems |
| **Session** | Medium | Medium | User sessions (default) |
| **Consistent Prefix** | Low | Low | Social updates |
| **Eventual** | Lowest | Lowest | Analytics, metrics |

> 📚 [Consistency Levels](https://learn.microsoft.com/azure/cosmos-db/consistency-levels)

---

# Microsoft Fabric Overview

| Component | Purpose |
|-----------|---------|
| **Lakehouse** | Unified data lake + warehouse |
| **Data Factory** | Data integration pipelines |
| **Synapse** | Analytics and data science |
| **Power BI** | Reporting and visualization |
| **Real-Time Analytics** | Streaming data processing |

> 📚 [Microsoft Fabric](https://learn.microsoft.com/fabric/get-started/microsoft-fabric-overview)

---

# 🖐️ Hands-on: Databases

**Exercise 9.1** — Create Cosmos DB
- Create serverless Cosmos DB account
- Create database and container

**Exercise 9.2** — Test App Connection
- Run Python test app with CRUD operations

📂 **See:** `lessons/09-database-services/README.md`

---

# ✅ Module 9 Summary

- Choose database type based on workload requirements
- Cosmos DB: global distribution, multiple APIs
- Session consistency is the default (good for most apps)
- Serverless Cosmos DB is great for dev/test

---

<!-- _class: lead -->

# Module 10
## Billing & Cost Optimization

---

# Cost Management Components

| Component | Description |
|-----------|-------------|
| **Cost Analysis** | Visualize and analyze spending |
| **Budgets** | Set limits with alerts |
| **Recommendations** | Azure Advisor suggestions |
| **Exports** | Schedule cost data exports |

> 📚 [Cost Management](https://learn.microsoft.com/azure/cost-management-billing/costs/overview-cost-management)

---

# Pricing Models

| Model | Savings | Best For |
|-------|---------|----------|
| **Pay-as-you-go** | None | Variable workloads |
| **Reserved Instances** | Up to 72% | Steady-state (1-3 years) |
| **Spot VMs** | Up to 90% | Fault-tolerant batch jobs |
| **Dev/Test** | ~50% | Non-production |
| **Hybrid Benefit** | Up to 40% | Existing licenses |

> 📚 [Azure Pricing](https://azure.microsoft.com/pricing/)

---

# Resource Tagging Strategy

| Tag | Purpose | Example |
|-----|---------|---------|
| `Environment` | Deployment stage | Production, Development |
| `Owner` | Responsible team | platform-team |
| `Project` | Application | azure-essentials |
| `CostCenter` | Billing allocation | CC-1234 |
| `Department` | Organization unit | Engineering |

> 📚 [Tagging Strategy](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-tagging)

---

# 🖐️ Hands-on: Cost Management

**Exercise 10.1** — Explore Cost Analysis
- Navigate Cost Management in Portal
- Explore views by service and resource group

**Exercise 10.2** — Create Budget
- Set monthly budget with alert thresholds

**Exercise 10.3** — Apply Tags
- Tag resource groups for cost tracking

📂 **See:** `lessons/10-billing-cost/README.md`

---

# ✅ Module 10 Summary

- Use Cost Analysis to understand spending
- Set budgets with alert thresholds
- Reserved Instances save up to 72%
- Tags are essential for cost allocation

---

<!-- _class: lead -->

# Module 11
## Azure AI Foundry

---

# Azure AI Foundry Components

| Component | Description |
|-----------|-------------|
| **AI Hub** | Central resource for AI projects |
| **AI Project** | Workspace for building AI apps |
| **Model Catalog** | Library of pre-trained models |
| **Prompt Flow** | Visual AI workflow orchestration |
| **Deployments** | Hosted model endpoints |

> 📚 [AI Foundry Overview](https://learn.microsoft.com/azure/ai-studio/what-is-ai-studio)

---

# Model Categories

| Category | Models | Use Cases |
|----------|--------|-----------|
| **OpenAI** | GPT-4, GPT-4o | Chat, reasoning |
| **Microsoft** | Phi-3, Phi-4 | Efficient small models |
| **Embedding** | text-embedding-ada-002 | Search, RAG |
| **Image** | DALL-E 3 | Image generation |
| **Speech** | Whisper | Speech-to-text |

> 📚 [Model Catalog](https://learn.microsoft.com/azure/ai-studio/how-to/model-catalog)

---

# Key Model Parameters

| Parameter | Description | Range |
|-----------|-------------|-------|
| **Temperature** | Randomness | 0.0 (focused) → 2.0 (creative) |
| **Max Tokens** | Response length | 1 → model max |
| **Top P** | Nucleus sampling | 0.0 → 1.0 |
| **Frequency Penalty** | Reduce repetition | 0.0 → 2.0 |

> 📚 [Model Parameters](https://learn.microsoft.com/azure/ai-services/openai/concepts/advanced-prompt-engineering)

---

# 🖐️ Hands-on: AI Foundry

**Exercise 11.1** — Create AI Hub & Project
- Navigate to ai.azure.com
- Create hub and project

**Exercise 11.2** — Deploy a Model
- Select and deploy gpt-4o-mini

**Exercise 11.3** — Build Simple Chatbot
- Test the deployed model

📂 **See:** `lessons/11-ai-foundry/README.md`

---

# ✅ Module 11 Summary

- AI Foundry: unified platform for AI development
- Model catalog: choose from OpenAI, Microsoft, and more
- Temperature controls response creativity
- Serverless API deployment is the easiest option

---

<!-- _class: lead -->

# Module 12
## Architecture Design

---

# Well-Architected Framework

| Pillar | Key Question |
|--------|--------------|
| **Reliability** | How will it handle failures? |
| **Security** | How is data protected? |
| **Cost Optimization** | What's the TCO? |
| **Operational Excellence** | How will you monitor? |
| **Performance Efficiency** | Will it scale? |

> 📚 [Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/)

---

# Design Scenario: E-Commerce

**Requirements:**
- Product catalog with search
- User authentication
- Shopping cart & checkout
- Order processing & notifications
- Admin dashboard

**Non-functional:**
- 99.9% availability
- <200ms response time
- 10,000 concurrent users

---

# Frontend Layer Options

| Service | Purpose | Why |
|---------|---------|-----|
| **Static Web Apps** | Host React/Vue | Serverless, CDN included |
| **Azure CDN** | Cache assets | Global edge delivery |
| **Azure Front Door** | Global load balancing | WAF, SSL, routing |

---

# API Layer Options

| Service | Purpose | Why |
|---------|---------|-----|
| **API Management** | Gateway | Rate limiting, caching |
| **App Service** | Host APIs | Easy scaling, managed |
| **Container Apps** | Modern APIs | Microservices, scale to zero |
| **Functions** | Event-driven | Per-request pricing |

---

# Data Layer Options

| Service | Purpose | Why |
|---------|---------|-----|
| **Cosmos DB** | Product catalog | Global read, flexible schema |
| **Azure SQL** | Orders | Transactions, ACID |
| **Redis Cache** | Sessions, cart | Low latency |
| **Blob Storage** | Product images | Cost-effective |

---

# Sample Architecture

```
                    ┌─────────────────┐
                    │  Azure Front    │
                    │  Door + WAF     │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
       ┌──────▼──────┐ ┌─────▼─────┐ ┌──────▼──────┐
       │Static Web   │ │   API     │ │  Functions  │
       │   Apps      │ │Management │ │  (Events)   │
       └─────────────┘ └─────┬─────┘ └──────┬──────┘
                             │              │
              ┌──────────────┼──────────────┤
              │              │              │
       ┌──────▼─────┐ ┌──────▼─────┐ ┌──────▼─────┐
       │  Cosmos DB │ │ Azure SQL  │ │Redis Cache │
       │  (Catalog) │ │  (Orders)  │ │ (Sessions) │
       └────────────┘ └────────────┘ └────────────┘
```

---

# 🖐️ Hands-on: Design Workshop

**Team Exercise (30 min):**

1. Draw architecture on whiteboard
2. Select services for each layer
3. Address the 5 WAF pillars
4. Present to the group

📂 **See:** `lessons/12-architecture-design/README.md`

---

# ✅ Module 12 Summary

- Apply Well-Architected Framework pillars
- Choose services based on requirements
- Consider scalability, reliability, cost
- Document and communicate decisions

---

<!-- _class: lead -->

# 🎓 Course Complete!

---

# Key Takeaways

| Day | Focus |
|-----|-------|
| **Day 1** | Foundations: Portal, CLI, Storage, Networking, Compute, Containers |
| **Day 2** | Advanced: Serverless, Databases, Cost, AI, Architecture |

**Remember:**
- Start with the right service model (IaaS/PaaS/SaaS)
- Use resource groups and tags for organization
- Apply Well-Architected Framework principles
- Monitor costs from day one

---

# Next Steps

| Resource | Description |
|----------|-------------|
| [AZ-900 Learning Path](https://learn.microsoft.com/training/paths/azure-fundamentals/) | Azure Fundamentals certification |
| [AZ-204 Learning Path](https://learn.microsoft.com/training/paths/create-azure-app-service-web-apps/) | Developer certification |
| [Azure Architecture Center](https://learn.microsoft.com/azure/architecture/) | Reference architectures |
| [Cloud Adoption Framework](https://learn.microsoft.com/azure/cloud-adoption-framework/) | Enterprise guidance |

---

# Resources

| Type | Link |
|------|------|
| 📖 Book | [Learning Microsoft Azure](https://www.oreilly.com/library/view/learning-microsoft-azure/9781098113315/) |
| 🎓 Training | [Azure Resource Center](https://azure.microsoft.com/resources/) |
| 🧪 Labs | [Cloud Labs: AZ-900](https://www.oreilly.com/member/playlists/1eb7c9e0-ede4-4c0f-9d80-c1ee5ab8e9c8/) |
| 📝 Exam | [AZ-900 Practice Test](https://www.pearsonitcertification.com/store/microsoft-azure-fundamentals-az-900-pearson-practice-9780137919918) |

---

# Questions?

**Contact:**
- Course Repository: github.com/codetocloudorg/azure_essentials
- Microsoft Learn: learn.microsoft.com

**Thank you for attending!**

![bg right:40% 80%](https://upload.wikimedia.org/wikipedia/commons/f/fa/Microsoft_Azure.svg)
