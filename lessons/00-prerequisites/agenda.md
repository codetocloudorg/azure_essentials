# Azure Essentials — Course Agenda

> **Code to Cloud** | 2-Day Hands-On Training
> 📅 Total Duration: ~10 hours across two days

---

## 📋 Prerequisites

Before attending, please ensure you have:

### Required Setup

- [ ] **Azure Account** — Free account works for most lessons ([Create free account](https://azure.microsoft.com/free/))
- [ ] **Azure CLI** — Version 2.50+ ([Install guide](https://learn.microsoft.com/cli/azure/install-azure-cli))
- [ ] **Azure Developer CLI (azd)** — Version 1.5+ ([Install guide](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd))
- [ ] **Git** — For cloning the repository ([Install Git](https://git-scm.com/downloads))
- [ ] **VS Code** with extensions:
  - Azure Tools
  - Bicep
  - HashiCorp Terraform
  - Kubernetes
  - Azure Logic Apps
  - Red Hat YAML
  - WSL (Windows only)

### Additional Tools (Installed by Setup Script)

The setup scripts (`setup-local-tools.sh` / `setup-local-tools.ps1`) will install these for you:

- **kubectl** — For Kubernetes lessons
- **Docker Desktop** — For container lessons
- **Python 3** — For sample applications
- **jq** — JSON processor for CLI workflows
- **Bicep CLI** — Infrastructure as Code

### Optional Tools

- Azure Storage Explorer — GUI for storage management
- Draw.io — Architecture diagrams

### Recommended Knowledge

- Basic understanding of computer systems and networking (IP addresses, DNS, firewalls)
- Familiarity with Windows and Linux fundamentals
- Some experience with command-line tools (PowerShell, Bash)
- Basic awareness of containers and Kubernetes concepts

### Quick Setup Commands

**macOS / Linux:**
```bash
./scripts/bash/setup-local-tools.sh
./scripts/bash/validate-env.sh
```

**Windows (PowerShell):**
```powershell
.\scripts\powershell\setup-local-tools.ps1
.\scripts\powershell\validate-env.ps1
```

👉 **[Complete Setup Guide](README.md)** — Detailed instructions for Windows, macOS, and Linux

---

## 📆 Day 1 — Foundations

### Module 1: Setting the Scene (55 min)

| Time | Topic | Type |
|------|-------|------|
| 30 min | Introduction to Azure Cloud | Presentation |
| | • Azure service models: IaaS, PaaS, SaaS, Serverless | |
| | • Azure global infrastructure | |
| 15 min | Azure Portal & CLI Basics | Demo + Hands-on |
| 10 min | Q&A | Discussion |

*☕ Break*

---

### Module 2: Getting Started with Azure (20 min)

| Time | Topic | Type |
|------|-------|------|
| 10 min | Accounts, Subscriptions & Tenants | Presentation |
| | • Management Groups and governance | |
| | • Resource groups and tagging | |
| 10 min | Create Resource Groups & Set Up CLI | Demo + Hands-on |

---

### Module 3: Storage Services (55 min)

| Time | Topic | Type |
|------|-------|------|
| 25 min | Azure Storage Deep Dive | Presentation |
| | • Blobs, Files, Queues, Tables | |
| | • Redundancy: LRS, ZRS, GRS | |
| | • Access tiers: Hot, Cool, Archive | |
| 20 min | Create Storage Account & Work with Blobs | Demo + Hands-on |
| 10 min | Q&A | Discussion |

*☕ Break*

---

### Module 4: Networking Services (35 min)

| Time | Topic | Type |
|------|-------|------|
| 15 min | Azure Networking Fundamentals | Presentation |
| | • Virtual Networks (VNets) and Subnets | |
| | • Network Security Groups (NSGs) | |
| | • Load Balancers and Private Endpoints | |
| 15 min | Create VNet and Configure NSG Rules | Demo + Hands-on |
| 5 min | Q&A | Discussion |

*☕ Break*

---

### Module 5: Compute — Windows (30 min)

| Time | Topic | Type |
|------|-------|------|
| 10 min | Windows VM Overview | Presentation |
| | • VM sizes and availability options | |
| | • Azure App Service basics | |
| 15 min | Deploy Windows VM + App Service | Demo + Hands-on |
| 5 min | Q&A | Discussion |

*☕ Break*

---

### Module 6: Compute — Linux & Kubernetes (25 min)

| Time | Topic | Type |
|------|-------|------|
| 10 min | Linux Workloads & K8s Fundamentals | Presentation |
| | • Linux VMs on Azure | |
| | • Kubernetes concepts and MicroK8s | |
| 15 min | Deploy Linux VM + MicroK8s Cluster | Demo + Hands-on |

---

### Module 7: Container Services (25 min)

| Time | Topic | Type |
|------|-------|------|
| 10 min | Azure Container Registry & AKS | Presentation |
| | • Building and pushing container images | |
| | • Azure Kubernetes Service overview | |
| 10 min | Build Container & Push to ACR | Demo + Hands-on |
| 5 min | Q&A | Discussion |

---

## 📆 Day 2 — Advanced Services

### Module 8: Serverless Services (60 min)

| Time | Topic | Type |
|------|-------|------|
| 25 min | Azure Functions Deep Dive | Presentation |
| | • Triggers and bindings | |
| | • Consumption vs. Premium plans | |
| | • Logic Apps for workflow automation | |
| 25 min | Build a Function + Logic App Workflow | Demo + Hands-on |
| 10 min | Q&A | Discussion |

*☕ Break*

---

### Module 9: Database & Data Services (60 min)

| Time | Topic | Type |
|------|-------|------|
| 25 min | Azure Data Platform Overview | Presentation |
| | • Azure SQL and PostgreSQL/MySQL | |
| | • Cosmos DB: multi-model, global distribution | |
| | • Microsoft Fabric: Lakehouse, Power BI, pipelines | |
| 25 min | Create Cosmos DB & Test App Connection | Demo + Hands-on |
| 10 min | Q&A | Discussion |

*☕ Break*

---

### Module 10: Billing & Cost Optimization (20 min)

| Time | Topic | Type |
|------|-------|------|
| 10 min | Cost Management Strategies | Presentation |
| | • Azure Cost Management tools | |
| | • Budgets, alerts, and tagging | |
| 10 min | Set Up Billing Alerts | Demo + Hands-on |

*☕ Break*

---

### Module 11: Azure AI Foundry (45 min)

| Time | Topic | Type |
|------|-------|------|
| 20 min | AI Foundry Platform Overview | Presentation |
| | • AI Hub and Project workspaces | |
| | • Model catalog: OpenAI, Phi, embeddings | |
| | • Prompt flow and orchestration | |
| 20 min | Build & Test a Simple Chatbot | Demo + Hands-on |
| 5 min | Q&A | Discussion |

---

### Module 12: Architecture Design (45 min)

| Time | Topic | Type |
|------|-------|------|
| 45 min | Collaborative Design Session | Workshop |
| | • Design a web frontend + database backend | |
| | • Apply Azure Well-Architected principles | |
| | • Team presentations and feedback | |

---

### Wrap-Up & Q&A (10 min)

- Course summary and key takeaways
- Recommended next steps
- Final questions

---

## 📚 Recommended Follow-Up

After completing this course, continue your Azure journey:

| Resource | Type | Description |
|----------|------|-------------|
| [Learning Microsoft Azure](https://www.oreilly.com/library/view/learning-microsoft-azure/9781098113315/) | 📖 Book | Comprehensive Azure guide |
| [Azure Resource Center](https://azure.microsoft.com/resources/) | 🎓 Playlist | Expert-curated learning paths |
| [Cloud Labs: AZ-900](https://www.oreilly.com/member/playlists/1eb7c9e0-ede4-4c0f-9d80-c1ee5ab8e9c8/) | 🧪 Labs | Interactive fundamentals labs |
| [How To Become a Cloud Solutions Architect](https://www.oreilly.com/videos/how-to-become/9780138270483/) | 🎥 Course | Career path guidance |
| [AZ-900 Practice Test](https://www.pearsonitcertification.com/store/microsoft-azure-fundamentals-az-900-pearson-practice-9780137919918) | 📝 Exam Prep | Certification preparation |

---

## 🔗 Quick Links

- [← Back to Prerequisites](README.md)
- [→ Start Lesson 01: Introduction](../01-introduction/README.md)
- [📂 Course Repository](../../README.md)
- [🚀 Deployment Scripts](../../scripts/bash/deploy.sh)

---

*Code to Cloud | www.codetocloud.io*
